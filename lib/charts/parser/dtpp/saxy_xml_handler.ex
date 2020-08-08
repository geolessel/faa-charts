defmodule Charts.Parser.DTPP.SaxyXMLHandler do
  @behaviour Saxy.Handler
  @initial_state %{
    airports: [],
    charts: [],
    cities: [],
    states: [],
    stack: []
  }

  def handle_event(:start_document, _prolog, _state) do
    {:ok, @initial_state}
  end

  def handle_event(:end_document, _data, state) do
    {:ok, state}
  end

  def handle_event(:start_element, {"digital_tpp", attrs}, state) do
    attrs = Enum.into(attrs, %{})

    dtpp = %Charts.DTPP{
      cycle: attrs["cycle"],
      from_edate: attrs["from_edate"],
      to_edate: attrs["to_edate"]
    }

    state =
      state
      |> Map.put(:dtpp, dtpp)
      |> Map.put(:stack, [dtpp | state.stack])

    {:ok, state}
  end

  def handle_event(:start_element, {"state_code", attrs}, state) do
    attrs = Enum.into(attrs, %{})
    st = %Charts.State{name: attrs["state_fullname"], abbreviation: attrs["ID"]}

    state =
      state
      |> Map.put(:states, [st | state.states])
      |> Map.put(:stack, [st | state.stack])

    {:ok, state}
  end

  def handle_event(:start_element, {"city_name", attrs}, state) do
    attrs = Enum.into(attrs, %{})
    city = %Charts.City{name: attrs["ID"], state: hd(state.stack), volume: attrs["volume"]}

    state =
      state
      |> Map.put(:cities, [city | state.cities])
      |> Map.put(:stack, [city | state.stack])

    {:ok, state}
  end

  def handle_event(:start_element, {"airport_name", attrs}, state) do
    attrs = Enum.into(attrs, %{})

    airport = %Charts.Airport{
      name: attrs["ID"],
      military: attrs["military"],
      apt_ident: attrs["apt_ident"],
      icao_ident: attrs["icao_ident"],
      alnum: attrs["alnum"],
      city: hd(state.stack)
    }

    state =
      state
      |> Map.put(:airports, [airport | state.airports])
      |> Map.put(:stack, [airport | state.stack])

    {:ok, state}
  end

  def handle_event(:start_element, {"record", _attrs}, state) do
    dtpp = state.stack |> Enum.reverse() |> hd()

    {:ok,
     state |> Map.put(:stack, [%Charts.Chart{airport: hd(state.stack), dtpp: dtpp} | state.stack])}
  end

  def handle_event(:start_element, {name, attributes}, state) do
    {:ok, [{:start_element, name, attributes} | state]}

    stack = [{name, attributes} | state.stack]
    {:ok, Map.put(state, :stack, stack)}
  end

  def handle_event(:end_element, "record", state) do
    state =
      state
      |> Map.put(:charts, [hd(state.stack) | state.charts])
      |> Map.put(:stack, tl(state.stack))

    {:ok, state}
  end

  def handle_event(:end_element, name, state) do
    {:ok, [{:end_element, name} | state]}

    state = Map.put(state, :stack, tl(state.stack))
    {:ok, state}
  end

  def handle_event(:characters, chars, state) do
    chars
    |> String.trim()
    |> handle_characters(state)
  end

  defp handle_characters("", state), do: {:ok, state}

  defp handle_characters(chars, state) do
    state =
      case Enum.take(state.stack, 2) do
        [{attr, _attributes} = record, %Charts.Chart{} = chart] ->
          chart =
            chart
            |> Map.put(String.to_atom(attr), chars)

          state
          |> Map.update(:stack, [], fn stack ->
            stack = Enum.drop(stack, 2)
            [record | [chart | stack]]
          end)

        _ ->
          state
      end

    {:ok, state}
  end
end
