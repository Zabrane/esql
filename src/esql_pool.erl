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

-export([child_spec/3, create_pool/3, delete_pool/1]).
-export([get_connection/1, return_connection/2]).

%% TODO: run, execute and execute1 can be removed.
-export([run/3, execute/3, execute1/3, transaction/2]). 
-export([with_connection/2]).

-export([open_esql_connection/1]).

%
% pool_connection
%    pool   :: Name
%    worker :: pid of the worker.

% @doc Return a child spec. 
child_spec(Name, Size, Options) ->
    esql_pool_sup:child_spec(Name, Size, Options).

% @doc Create a new pool
create_pool(Name, Size, Options) ->
    Opts = case proplists:get_bool(serialized, Options) of
        true ->
            [{connection, open_esql_connection(Options)} | Options];
        _ -> 
            Options
    end,
    esql_pool_sup:create_pool(Name, Size, Opts).

% @doc Open a esql connection with the values from the option list.
%
open_esql_connection(Options) ->
    Driver = proplists:get_value(driver, Options),
    Args = proplists:get_value(args, Options),
    {ok, Connection} = esql:open(Driver, Args),
    Connection.

% @doc Delete the pool
delete_pool(Name) ->
    esql_pool_sup:delete_pool(Name).

% @doc Get a database connection.
%
get_connection(PoolName) ->
    poolboy:checkout(PoolName).

% @doc And return it.
return_connection(Worker, PoolName) ->
    poolboy:checkin(PoolName, Worker).

% @doc Run a query with the props, returns nothing.
run(Sql, Props, Connection) ->
    with_connection(fun(C) -> esql:run(Sql, Props, C) end, Connection).

% @doc Execute a query with the props, returns the result.
execute(Sql, Props, Connection) ->
    with_connection(fun(C) -> esql:execute(Sql, Props, C) end, Connection).

% @doc Execute a query with the props, returns the result.
execute1(Sql, Props, Connection) ->
    with_connection(fun(C) -> esql:execute1(Sql, Props, C) end, Connection).

% @doc Execute a transaction on the given pool.
transaction(F, Connection) ->
    with_connection(fun(C) -> esql:transaction(F, C) end, Connection).

% @doc Execute a funtion on connection or take one from the pool. 
% The function gets a esql connection.
% apply_f(F, Connection) when is_pid(Connection) ->
%    gen_server:call(Connection, {with_connection, F});
% apply_f(F, Name) ->
%    with_connection(fun(C) -> apply_f(F, C) end, Name).

% @doc Run the function
with_connection(F, Connection) when is_pid(Connection) ->
    gen_server:call(Connection, {with_connection, F});
with_connection(F, Name) ->
    Conn = get_connection(Name),
    try
        with_connection(F, Conn)
        % F(Conn)
    after
        return_connection(Conn, Name)
    end.
