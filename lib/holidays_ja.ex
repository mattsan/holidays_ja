defmodule HolidaysJa do
  @moduledoc """
  Public holidays in Japan.

  see [国民の祝日について - 内閣府](https://www8.cao.go.jp/chosei/shukujitsu/gaiyou.html)
  """

  alias HolidaysJa.Holiday

  @holiday_url Application.get_env(:holidays_ja, :url)

  def load(filename) do
    File.stream!(filename)
    |> CSV.decode!(headers: [:date, :name])
    |> Enum.map(fn %{date: date, name: name} -> %Holiday{date: date, name: name} end)
  end

  def save(holidays, filename) do
    File.open(filename, [:write, :utf8], fn file ->
      holidays
      |> CSV.encode(headers: [:date, :name])
      |> Stream.each(&IO.write(file, &1))
      |> Enum.to_list()
    end)
  end

  def fetch do
    {:ok, response} = HTTPoison.get(@holiday_url)
    [_ | days] = :iconv.convert("SJIS", "UTF-8", response.body) |> String.split()

    days
    |> Enum.map(&to_holiday/1)
  end

  defp to_holiday(s) do
    [date_str, name] = String.split(s, ",", trim: true)

    date =
      date_str
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
      |> Date.from_erl!()

    %Holiday{date: date, name: name}
  end
end
