defmodule Timber.Events.CustomEvent do
  @moduledoc """
  Allows for custom events that aren't covered elsewhere.

  Custom events can be used to encode information about events that are central
  to your line of business like receiving credit card payments, adding products
  to a card, saving a draft of a post, or changing a user's password.

  ## Fields

    * `name` - This is the name of your event. This can be anything that adheres
      to the `String.Chars' protocol. It will be used to identify this event on the Timber
      interface. Example: `:my_event` or or `MyEvent`. At Timber we like to reserve CamelCase
      events for actual modules and snake_case events for inline events.
    * `data` - A map of data. This can be anything that implemented the `Poison.Encoder`
      protocol. That is, anything that can be JSON encoded. example: `%{key: "value"}`
    * `time_ms` - A fractional float represented the execution time in milliseconds.
      example: `45.6`

  ## Examples

  Please see `Timber.Event` for examples on passing custom event information.

  """

  alias Timber.Timer

  @type t :: %__MODULE__{
    name: String.t,
    data: map() | nil,
    time_ms: float() | nil
  }

  @enforce_keys [:name]
  defstruct [
    :data,
    :name,
    :time_ms
  ]

  @doc ~S"""
  Creates a new custom event. Takes any of the fields described in the module docs as keys.

  ## Additional options

    * `timer` - The value returned when calling `Timber.Timer.start()`. By passing this
      `time_ms` will automatically be set for you.
  """
  @spec new(Keyword.t) :: t
  def new(opts) do
    timer = Keyword.get(opts, :timer)
    if timer do
      time_ms = Timer.duration_ms(timer)
      opts
      |> Keyword.delete(:timer)
      |> Keyword.put(:time_ms, time_ms)
    else
      opts
    end
    struct(__MODULE__, opts)
  end
end
