%% @author Maas-Maarten Zeeman <mmzeeman@xs4all.nl>
%% @copyright 2012 Maas-Maarten Zeeman
%% 
%% @doc Erlang Database Connection Framework
%% 
%% Copyright 2012 Maas-Maarten Zeeman
%% 
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%% 
%% http://www.apache.org/licenses/LICENSE-2.0
%% 
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(esql_pool).

-export([create_pool/3, delete_pool/1]).

-export([get_connection/1, return_connection/2]).

%% Work in progress.

% @doc Create a new pool
create_pool(Name, Size, Options) ->
    esql_pool_sup:create_pool(Name, Size, Options).

% @doc Delete the pool
delete_pool(Name) ->
    esql_pool_sup:delete_pool(Name).

% @doc
get_connection(PoolName) ->
    poolboy:checkout(PoolName),

% @doc
return_connection(Worker, PoolName) ->
    poolboy:checkin(PoolName, Worker).
