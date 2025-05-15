defmodule equipment do
  use GenServer

  # Public API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_item(key, item, metadata \\ %{}) when key in [:F1, :F2, :F3, :F4, :F5, :F6,
                                               :F7, :F8, :F9, :F10, :F11, :F12] do
    GenServer.cast(__MODULE__, {:add_item, key, item, metadata})
  end

  def get_item(key) when key in [:F1, :F2, :F3, :F4, :F5, :F6,
                                :F7, :F8, :F9, :F10, :F11, :F12] do
    GenServer.call(__MODULE__, {:get_item, key})
  end

  # GenServer Callbacks
  def init(_) do
    # Initialize with empty equipment slots
    state = Enum.reduce(1..12, %{}, fn n, acc ->
      Map.put(acc, :"F#{n}", %{item: nil, metadata: %{}})
    end)

    # Start keyboard listener
    :keyboard.start_link(self())
    {:ok, state}
  end

  def handle_cast({:add_item, key, item, metadata}, state) do
    new_state = Map.put(state, key, %{item: item, metadata: metadata})
    {:noreply, new_state}
  end

  def handle_call({:get_item, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  # Handle F-key presses from keyboard driver
  def handle_info({:key_press, key}, state) when key in [:F1, :F2, :F3, :F4, :F5, :F6,
                                                       :F7, :F8, :F9, :F10, :F11, :F12] do
    case state[key] do
      %{item: nil} ->
        IO.puts("Slot #{key} is empty!")
      %{item: item, metadata: meta} ->
        handle_equipment_use(item, meta)
    end
    {:noreply, state}
  end

  defp handle_equipment_use(item, metadata) do
    # Custom equipment activation logic
    IO.puts("Activating #{item}!")
    # Example: Send equipment effects to game systems
    :game_engine.dispatch(:equipment_used, %{
      item: item,
      timestamp: System.system_time(:millisecond),
      metadata: metadata
    })
  end

  # Macro for defining equipment behaviors
  defmacro __using__(_opts) do
    quote do
      @equipment_slots Enum.map(1..12, &:"F#{&1}")

      defmacro equip_fkey(key, do: block) when key in @equipment_slots do
        quote do
          def handle_equipment_use(unquote(key), var!(metadata)) do
            unquote(block)
          end
        end
      end
    end
  end
end
