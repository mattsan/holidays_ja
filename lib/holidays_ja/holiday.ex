defmodule HolidaysJa.Holiday do
  defstruct [:date, :name]

  alias HolidaysJa.Holiday

  @holiday_url Application.get_env(:holidays_ja, :url)

  def lookup(holidays, year) do
    holidays
    |> Enum.filter(fn h -> h.date.year == year end)
  end

  def load(filename) do
    File.stream!(filename)
    |> CSV.decode!(headers: true)
    |> Enum.map(fn %{"date" => date, "name" => name} -> %Holiday{date: Date.from_iso8601!(date), name: name} end)
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
