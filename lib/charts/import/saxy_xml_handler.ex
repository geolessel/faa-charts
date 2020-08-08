defmodule Charts.Import.SaxyXMLHandler do
  @behaviour Saxy.Handler
  @initial_state %{
    airports: [],
    cities: [],
    states: [],
    stack: []
  }

  def handle_event(:start_document, prolog, _state) do
    # {:ok, [{:start_document, prolog} | state]}
    {:ok, @initial_state}
  end

  def handle_event(:end_document, _data, state) do
    # {:ok, [{:end_document} | state]}
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

  def handle_event(:start_element, {name, attributes}, state) do
    {:ok, [{:start_element, name, attributes} | state]}

    # IO.inspect({name, attributes}, label: "unhandled start element")

    stack = [{name, attributes} | state.stack]
    {:ok, Map.put(state, :stack, stack)}
  end

  def handle_event(:end_element, name, state) do
    {:ok, [{:end_element, name} | state]}

    state = Map.put(state, :stack, tl(state.stack))
    {:ok, state}
  end

  def handle_event(:characters, chars, state) do
    # {:ok, [{:chacters, chars} | state]}
    chars
    |> String.trim()
    |> handle_characters(state)
  end

  defp handle_characters("", state), do: {:ok, state}

  defp handle_characters(chars, state) do
    # IO.inspect(chars, label: "unhandled characters")
    {:ok, state}
  end
end
