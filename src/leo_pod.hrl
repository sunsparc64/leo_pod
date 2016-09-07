%%======================================================================
%%
%% Leo POD
%%
%% Copyright (c) 2012-2016 Rakuten, Inc.
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

-define(DEF_NUM_OF_CHILDREN, 8).
-type(pod_id() :: atom()).


-record(pod_state, {num_of_working_refs = 0 :: non_neg_integer(),
                    num_of_waiting_refs = 0 :: non_neg_integer(),
                    num_of_buffers = 0 :: non_neg_integer()
                   }).

-define(env_num_of_children(),
        application:get_env(
          leo_pod, 'num_of_children', ?DEF_NUM_OF_CHILDREN)).

-define(new_pod_params_tbl(_PodId),
        begin
            case ets:info(_PodId) of
                undefined ->
                    case catch ets:new(_PodId, [set, protected,
                                                named_table,
                                                {read_concurrency, true}]) of
                        _PodId ->
                            ok;
                        {'EXIT', Cause} ->
                            {error, Cause}
                    end;
                _ ->
                    ok
            end
        end).

-define(delete_pod_params_tbl(_PodId),
        begin
            case ets:info(_PodId) of
                undefined ->
                    ok;
                _ ->
                    case catch  ets:delete(_PodId) of
                        {'EXIT', Cause} ->
                            {error, Cause};
                        true ->
                            ok
                    end
            end
        end).

-define(get_pod_params(_PodId),
        begin
            case ets:info(_PodId) of
                undefined ->
                    not_found;
                _ ->
                    case ets:lookup(_PodId, 'config') of
                        [] ->
                            not_found;
                        [{_,_Conf}|_] ->
                            _Conf
                    end
            end
        end).

-define(put_pod_params(_PodId,_Params),
        begin
            case ets:info(_PodId) of
                undefined ->
                    not_exists_table;
                _ ->
                    case catch  ets:insert(_PodId, 'config',_Params) of
                        {'EXIT', Cause} ->
                            {error, Cause};
                        true ->
                            ok
                    end
            end
        end).

-define(create_manager_id(_PodId,_ChildId),
        begin
            list_to_atom(
              lists:append([atom_to_list(_PodId), "_", integer_to_list(_ChildId)]))
        end).

-define(get_manager_id(_PodId,_NumOfChildren),
        begin
            {H,S,M} = os:timestamp(),
            Clock = 1000000000000 * H + (S * 1000000 + M),
            _ChildId = (Clock rem _NumOfChildren) + 1,
            ?create_manager_id(_PodId,_ChildId)
        end).
