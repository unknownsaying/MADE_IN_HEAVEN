defmodule SpacetimeScalar do
  use GenServer

  # Public API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Initialize 12D spacetime coordinates (F1-F12 mapped to dimensions)
  def init(_) do
    state = %{
      dimensions: Enum.reduce(1..12, %{}, &Map.put(&2, :"F#{&1}", 0.0)),
      metric: :minkowski,  # Default metric signature
      observers: []
    }

    # Start keyboard listener (simulated for example)
    :keyboard.start(self())
    {:ok, state}
  end

  # Handle F-key presses to manipulate dimensions
  def handle_info({:key_press, key}, state) when key in [:F1, :F2, :F3, :F4, :F5, :F6,
                                                       :F7, :F8, :F9, :F10, :F11, :F12] do
    new_state = update_dimension(state, key, :os.system_time(:microsecond) / 1_000_000)
    {:noreply, new_state}
  end

  # Scalar field calculation (Lorentzian-inspired example)
  defp calculate_scalar(dimensions, metric) do
    # Simplified 12D "interval" calculation
    dimensions
    |> Map.values()
    |> Enum.reduce(0, fn x, acc -> acc + x * x end)
    |> apply_metric(metric)
  end

  defp apply_metric(value, :minkowski) do
    # Last dimension treated as timelike (- sign convention)
    timelike = List.last(Map.values(value))
    value - 2 * timelike * timelike
  end

  # Dimension update logic
  defp update_dimension(state, key, value) do
    new_dims = Map.put(state.dimensions, key, value)
    scalar = calculate_scalar(new_dims, state.metric)

    # Notify observers of spacetime changes
    Enum.each(state.observers, &send(&1, {:scalar_update, scalar}))

    %{state | dimensions: new_dims}
  end

  # Metric tensor control
  def handle_call({:set_metric, new_metric}, _from, state) do
    {:reply, :ok, %{state | metric: new_metric}}
  end

  # Observer pattern for spacetime events
  def handle_cast({:add_observer, pid}, state) do
    {:noreply, %{state | observers: [pid | state.observers]}}
  end
end
