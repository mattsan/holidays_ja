defmodule HolidaysJa do
  @moduledoc """
  Public holidays in Japan.

  see [国民の祝日について - 内閣府](https://www8.cao.go.jp/chosei/shukujitsu/gaiyou.html)
  """

  alias HolidaysJa.{Holiday, Worker}

  defdelegate load(filename), to: Holiday
  defdelegate save(holidays, filename), to: Holiday
  defdelegate fetch, to: Holiday

  defdelegate store(holidays), to: Worker
  defdelegate stored?, to: Worker
  defdelegate all, to: Worker
  defdelegate lookup(year), to: Worker
  defdelegate lookup(year, month), to: Worker
  defdelegate is_holiday?(date), to: Worker

  def lookup_as_map(year) do
    lookup(year)
    |> Enum.map(&{&1.date, &1.name})
    |> Map.new
  end
end
