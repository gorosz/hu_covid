defmodule HuCovid do
  @moduledoc """
  Documentation for `HuCovid`.
  """

  @doc """
  Get data from https://koronavirus.gov.hu/elhunytak
  Parse raw html and transform it to json
  """
  def get_data do
    {:ok, response} = HTTPoison.get("https://koronavirus.gov.hu/elhunytak")
    {:ok, html_tree} = Floki.parse_document(response.body)

    headers =
      html_tree
      |> Floki.find("thead")
      |> Floki.find("th")
      |> Enum.map(fn t ->
        [head | _tail] = elem(t, 2)
        String.trim(head)
      end)

    data_rows =
      html_tree
      |> Floki.find("tbody")
      |> Floki.find("tr")
      |> Enum.map(fn t ->
        for t2 <- elem(t, 2), do: get_text_from(t2)
      end)

    Enum.map(data_rows, fn l -> Enum.zip(headers, l) |> Enum.into(%{}) end)
    |> Jason.encode!
  end

  defp get_text_from(tuple) do
    [head | _tail] = elem(tuple, 2)
    String.trim(head)
  end
end
