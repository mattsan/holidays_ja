defmodule HolidaysJa.Holiday do
  defstruct [:date, :name]

  alias HolidaysJa.Holiday

  @holiday_url Application.get_env(:holidays_ja, :url)
  @date_format_regex ~r"^(\d{4})[.-/](\d{1,2})[.-/](\d{1,2})$"

  def lookup(holidays, filter) do
    case filter do
      [year: year] ->
        for (%{date: %{year: ^year}} = holiday) <- holidays, do: holiday

      [year: year, month: month] ->
        for (%{date: %{year: ^year, month: ^month}} = holiday) <- holidays, do: holiday
    end
  end

  def is_holiday?(holidays, %Date{} = date) do
    result = for %{date: ^date} <- holidays, do: true
    case result do
      [true] -> true
      [] -> false
    end
  end

  def is_holiday?(holidays, {y, m, d} = erl_date) when is_integer(y) and is_integer(m) and is_integer(d) do
    case Date.from_erl(erl_date) do
      {:ok, date} -> is_holiday?(holidays, date)
      _ -> false
    end
  end

  def is_holiday?(holidays, s) when is_binary(s) do
    with [_ | s] <- Regex.run(@date_format_regex, s),
         [year, month, day] <- Enum.map(s, &String.to_integer/1),
         {:ok, date} <- Date.from_erl({year, month, day}) do
      is_holiday?(holidays, date)
    end
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
