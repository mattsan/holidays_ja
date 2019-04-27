defmodule HolidaysJa.Worker do
  use GenServer

  alias HolidaysJa.Holiday
  require Logger

  @name __MODULE__

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  def init(args) do
    case args[:csv] do
      nil -> fetch()
      filename -> load(filename)
    end

    {:ok, %{holidays: [], stored: false}}
  end

  def load(filename) do
    Logger.debug "loading from #{filename}..."
    holidays = Holiday.load(filename)
    store(holidays)
  end

  def fetch do
    Logger.debug "fetching..."
    holidays = Holiday.fetch
    store(holidays)
  end

  def store(holidays) do
    GenServer.cast(@name, {:store, holidays})
  end

  def stored? do
    GenServer.call(@name, :stored)
  end

  def lookup(year) do
    GenServer.call(@name, {:lookup, :year, year})
  end

  def handle_cast({:store, holidays}, state) do
    Logger.debug "stored #{Enum.count(holidays)} days"
    {:noreply, %{state | holidays: holidays, stored: true}}
  end

  def handle_call(:stored, _from, state) do
    {:reply, state.stored, state}
  end

  def handle_call({:lookup, :year, year}, _from, state) do
    holidays = Holiday.lookup(state.holidays, year)
    {:reply, holidays, state}
  end
end
