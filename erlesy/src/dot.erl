-module(dot).

-include("types.hrl").


%% API
-export([digraph_to_dot/2, digraph_to_plantuml/2, filter_newline/1]).

digraph_to_dot(Name, G) ->
    "digraph \"" ++ Name ++ "\" { \n" ++
    %% These next few elements are added as they look a bit nicer in http://www.webgraphviz.com for the test,
    %% @TODO make these dynamic based on the diagraph data to beautify the display
    "rankdir=LR;\n" ++
    "edge [fontsize=10];\n" ++
    "node [shape=circle];\n" ++
    "ranksep = 2;\n" ++
    "nodesep = 0.5\n" ++
    edges_to_dot(G, digraph:edges(G)) ++
    "}".

edges_to_dot(_G, []) ->
    "\n";
edges_to_dot(G, [E|T]) ->
    {E, V1, V2, EdgeLabel} = digraph:edge(G, E),
    {_, VLabel1} = digraph:vertex(G, V1),
    {_, VLabel2} = digraph:vertex(G, V2),
  case EdgeLabel#edge_data.guard of
    [] ->
      R= io_lib:format("~s",[filter_newline(lists:flatten(EdgeLabel#edge_data.event))]);
    Guard ->
      R= io_lib:format("~s [~s]",[filter_newline(lists:flatten(EdgeLabel#edge_data.event)), Guard])
  end,

  %EdgePretty=lists:flatten(R),
  atom_to_list(VLabel1) ++ "->" ++ atom_to_list(VLabel2) ++
    "[label=\"" ++ R ++ "\"]" ++
    "\n" ++
    edges_to_dot(G, T).


digraph_to_plantuml(_Name, G) ->
  "@startuml\n"  ++
    edges_to_plantuml(G, digraph:edges(G)) ++
    "@enduml".

edges_to_plantuml(_G, []) ->
  "\n";
edges_to_plantuml(G, [E|T]) ->
  {E, V1, V2, EdgeLabel} = digraph:edge(G, E),
  {_, VLabel1} = digraph:vertex(G, V1),
  {_, VLabel2} = digraph:vertex(G, V2),
  FilteredEvent = filter_newline(lists:flatten(EdgeLabel#edge_data.event)),
  case EdgeLabel#edge_data.guard of
    [] ->
      R= io_lib:format("~s",[FilteredEvent]);
    Guard ->
      R= io_lib:format("~s [~s]",[FilteredEvent, Guard])
  end,

  %EdgePretty=lists:flatten(R),
  case R of
    [[]] ->
      statename(VLabel1) ++ "-->" ++ statename(VLabel2) ++
        "\n" ++
        edges_to_plantuml(G, T);
    _ ->
      statename(VLabel1) ++ "-->" ++ statename(VLabel2) ++
        " : " ++ R ++
        "\n" ++
        edges_to_plantuml(G, T)
  end.

statename(init) ->
  "[*]";
statename(terminate)->
  "[*]";
statename(Other) ->
  atom_to_list(Other).


filter_newline(List)->
  filter_newline(List, not_found, []).


filter_newline([$\n|T], found, Acc) ->
  filter_newline(T, not_found, Acc ++ [$\\]);
filter_newline([$\n|T], not_found, Acc) ->
  filter_newline(T, not_found, Acc);
filter_newline([$n|T], found, Acc) ->
  filter_newline(T, not_found, Acc);
filter_newline([$n|T], not_found, Acc) ->
  filter_newline(T, not_found, Acc ++ [$n]);
filter_newline([$\\|T], not_found, Acc) ->
  filter_newline(T, found, Acc);
filter_newline([$\\|T], found, Acc) ->
  filter_newline(T, not_found, Acc ++ [$\\]);
filter_newline([H|T], found, Acc) ->
  filter_newline(T, not_found, Acc ++ [$\\, H]);
filter_newline([H|T], not_found, Acc) ->
  filter_newline(T, not_found, Acc ++ [H]);
filter_newline([], _, Acc) ->
  Acc.




