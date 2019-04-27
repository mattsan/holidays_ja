defmodule HolidaysJa do
  @moduledoc """
  Public holidays in Japan.

  see [国民の祝日について - 内閣府](https://www8.cao.go.jp/chosei/shukujitsu/gaiyou.html)
  """

  @holiday_url Application.get_env(:holidays_ja, :url)

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

    {date, name}
  end
end
