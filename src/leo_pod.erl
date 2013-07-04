%%======================================================================
%%
%% Leo POD
%%
%% Copyright (c) 2012-2013 Rakuten, Inc.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%%======================================================================
-module(leo_pod).

-author('Yosuke Hara').

-include("leo_pod.hrl").
-include_lib("eunit/include/eunit.hrl").

%% API
-export([child_spec/5,
         checkout/1,
         checkin/2]).


%% ===================================================================
%% API functions
%% ===================================================================
%% @doc Set child worker's spec and launch a proc
%%
child_spec(Name, PodSize, MaxOverflow, WorkerMod, WorkerArgs) ->
    leo_pod_sup:start_link(Name, PodSize, MaxOverflow, WorkerMod, WorkerArgs).


%% @doc Checkout a worker from the pod_manager
%%
checkout(PodName) ->
    MgrId = ?gen_manager_id(PodName),
    leo_pod_manager:checkout(MgrId).


%% @doc Checkin a worker into the pod_manager
%%
checkin(PodName, Worker) ->
    MgrId = ?gen_manager_id(PodName),
    leo_pod_manager:checkin(MgrId, Worker).


%% ===================================================================
%% Internal functions
%% ===================================================================
