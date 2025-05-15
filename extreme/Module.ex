defmodule HyperDimensionalKeys do
  use GenServer

  @f_keys Enum.map(1..12, &:"F#{&1}")
  @symbols [:x, :y, :z, :t, :a, :b, :c, :d, :e, :f, :zero, :null]

  # Public API
  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def get(key) when key in @f_keys, do: GenServer.call(__MODULE__, {:get, key})
  def set(key, value) when key in @f_keys, do: GenServer.cast(__MODULE__, {:set, key, value})

  # GenServer Callbacks
  def init(_) do
    state =
      @symbols
      |> Enum.zip(@f_keys)
      |> Enum.into(%{})
      |> Map.merge(%{values: initialize_values()})

    # Start keyboard listener (simulated)
    :keyboard.start(self())
    {:ok, state}
  end

  def handle_call({:get, key}, _from, %{values: values} = state) do
    {:reply, Map.get(values, key), state}
  end

  def handle_cast({:set, key, value}, %{values: values} = state) do
    new_values = Map.put(values, key, value)
    {:noreply, %{state | values: new_values}}
  end

  # Handle F-key press events
  def handle_info({:key_press, key}, state) when key in @f_keys do
    value = state.values[key]
    symbolic = state.symbolic_map[key]

    IO.puts("""
    Key Pressed: #{key}
    Symbol: #{symbolic}
    Current Value: #{inspect(value)}
    """)

    {:noreply, state}
  end

  # Initialize values with symbolic defaults
  defp initialize_values do
    %{
      F1: %{type: :spatial, value: {0,0,0}},
      F2: %{type: :spatial, value: {0,0,0}},
      F3: %{type: :temporal, value: :os.system_time(:second)},
      F4: %{type: :abstract, value: nil},
      F5: :a,
      F6: :b,
      F7: :c,
      F8: :d,
      F9: :e,
      F10: :f,
      F11: 0,
      F12: nil
    }
  end

  # Symbolic mapping
  defp symbolic_map do
    %{
      F1: :x,
      F2: :y,
      F3: :z,
      F4: :t,
      F5: :a,
      F6: :b,
      F7: :c,
      F8: :d,
      F9: :e,
      F10: :f,
      F11: :zero,
      F12: :null
    }
  end
end
@symbols [:x, :y, :z, :t, :a, :b, :c, :d, :e, :f, :zero, :null]
@f_keys Enum.map(1..12, &:"F#{&1}")
