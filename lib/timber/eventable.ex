defprotocol Timber.Eventable do
  @moduledoc ~S"""
  Protocol that converts a data structure into a `Timber.Event.t`.

  This is called on any data structure used in the `:event` metadata key passed to `Logger` calls.

  ## Example

  For example, you can use this protocol to pass format event structs:

      defmodule OrderPlacedEvent do
        defstruct [:order_id, :total]

        defimpl Timber.Eventable do
          def to_event(event) do
            map = Map.from_struct(event)
            %{order_placed: map}
          end
        end
      end

    Then you can use it like so:

      Logger.info(fn ->
        event = %OrderPlacedEvent{order_id: "abcd", total: 100.23}
        message = "Order #{event.id} placed"
        {message, event: event}
      end)

  """

  @fallback_to_any true

  @doc """
  Converts the data structure into a `Timber.Event.t`.
  """
  @spec to_event(any) :: Timber.Event.t()
  def to_event(data)
end

defimpl Timber.Eventable, for: Map do
  def to_event(%{type: type, data: data}) do
    %{type => data}
  end

  def to_event(map) do
    map
  end
end

defimpl Timber.Eventable, for: Any do
  @upper_word_regex ~r/(^[A-Z]+$)|[A-Z][a-z0-9]*/

  def to_event(%{__exception__: true} = error) do
    message = Exception.message(error)
    module_name = Timber.Utils.Module.name(error.__struct__)

    %{
      error: %{
        name: module_name,
        message: message
      }
    }
  end

  def to_event(%{__struct__: module} = struct) do
    event_data = struct |> Map.from_struct()

    event_namespace =
      module
      |> Module.split()
      |> List.last()
      |> String.split(@upper_word_regex, trim: true, include_captures: true)
      |> Stream.map(&String.downcase/1)
      |> Enum.join("_")
      |> String.to_atom()

    Map.new([{event_namespace, event_data}])
  end
end
