{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications  #-}
{-# LANGUAGE GADTs             #-}

-- | Tests for "Fencer.Server".
module Fencer.Server.Test
  ( test_serverResponseNoRules
  , createServerAppState
  , destroyServerAppState
  )
where

import           BasePrelude

import           Test.Tasty (TestTree, withResource)
import           Test.Tasty.HUnit (assertEqual, assertFailure, testCase)
import qualified System.Logger as Logger
import qualified Network.GRPC.HighLevel.Generated as Grpc

import           Fencer.AppState
import           Fencer.Server
import           Fencer.Settings (defaultGRPCPort)
import           Fencer.Types (unPort)
import qualified Fencer.Proto as Proto

----------------------------------------------------------------------------
-- Tests
----------------------------------------------------------------------------

-- | Test that when Fencer is started without any rules provided to it (i.e.
-- 'reloadRules' has never been ran), requests to Fencer will error out.
--
-- This behavior matches @lyft/ratelimit@.
test_serverResponseNoRules :: TestTree
test_serverResponseNoRules =
  withResource createServer destroyServer $ \_ ->
    testCase "When no rules have been loaded, all requests error out" $ do
      -- NOTE(md): For reasons unkown, the delay in the thread makes a
      -- server test failure for 'test_serverResponseNoRules' go
      -- away. The delay was introduced by assuming it might help
      -- based on the issue comment in gRPC's source code repository:
      -- https://github.com/grpc/grpc/issues/14088#issuecomment-365852100
      --
      -- The length of the delay was fine tuned based on feedback from
      -- test execution.
      --
      -- This delay interacts with the order of the rules and server
      -- tests, which would have executed concurrently by default if
      -- 'after' wasn't used in the Main test module.
      threadDelay 5000 -- 5 ms

      Grpc.withGRPCClient clientConfig $ \grpcClient -> do
        client <- Proto.rateLimitServiceClient grpcClient
        response <-
          Proto.rateLimitServiceShouldRateLimit client $
            Grpc.ClientNormalRequest request 1 mempty
        case response of
          Grpc.ClientErrorResponse actualError ->
            assertEqual "Got wrong gRPC error response"
              expectedError
              actualError
          Grpc.ClientNormalResponse result _ _ status _ -> do
            assertFailure $
              "Expected an error response, got a normal response: " ++
              "status = " ++ show status ++ ", " ++
              "result = " ++ show result
  where
    -- Sample request.
    request :: Proto.RateLimitRequest
    request = Proto.RateLimitRequest
      { Proto.rateLimitRequestDomain = "domain"
      , Proto.rateLimitRequestDescriptors = mempty
      , Proto.rateLimitRequestHitsAddend = 0
      }

    -- The exact error lyft/ratelimit returns when no rules have been loaded.
    expectedError :: Grpc.ClientError
    expectedError =
      Grpc.ClientIOError
        (Grpc.GRPCIOBadStatusCode
           Grpc.StatusUnknown
           (Grpc.StatusDetails
              "rate limit descriptor list must not be empty"))

----------------------------------------------------------------------------
-- gRPC server
----------------------------------------------------------------------------

-- | Start Fencer on the default port.
createServer :: IO (Logger.Logger, ThreadId)
createServer = do
  (logger, threadId, _) <- createServerAppState
  pure (logger, threadId)

-- | Start Fencer on the default port.
createServerAppState :: IO (Logger.Logger, ThreadId, AppState)
createServerAppState = do
  -- TODO: not the best approach. Ideally we should use e.g.
  -- https://hackage.haskell.org/package/tasty-hunit/docs/Test-Tasty-HUnit.html#v:testCaseSteps
  -- but we can't convince @tinylog@ to use the provided step function.
  logger <- Logger.create (Logger.Path "/dev/null")
  appState <- initAppState
  threadId <- forkIO $ runServer logger appState
  pure (logger, threadId, appState)

-- | Kill Fencer.
destroyServer :: (Logger.Logger, ThreadId) -> IO ()
destroyServer (logger, threadId) = do
  Logger.close logger
  killThread threadId

-- | Kill Fencer.
destroyServerAppState :: (Logger.Logger, ThreadId, AppState) -> IO ()
destroyServerAppState (logger, threadId, _) = destroyServer (logger, threadId)

----------------------------------------------------------------------------
-- gRPC client
----------------------------------------------------------------------------

-- | gRPC config that can be used to connect to Fencer started with
-- 'createServer'.
clientConfig :: Grpc.ClientConfig
clientConfig = Grpc.ClientConfig
  { Grpc.clientServerHost = "localhost"
  , Grpc.clientServerPort = fromIntegral . unPort $ defaultGRPCPort
  , Grpc.clientArgs = []
  , Grpc.clientSSLConfig = Nothing
  , Grpc.clientAuthority = Nothing
  }
