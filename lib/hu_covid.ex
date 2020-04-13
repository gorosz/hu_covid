defmodule HuCovid do
  @moduledoc """
  Documentation for `HuCovid`.
  """

  @doc """
  Get data from https://koronavirus.gov.hu/elhunytak
  Parse raw html and transform it to json
  """
  @base_url "https://koronavirus.gov.hu"

  def get_data do
    html_tree = parse_response_body("#{@base_url}/elhunytak")

    next_btn = next_button_element(html_tree)
    headers = parse_headers(html_tree)
    data_rows = get_paginated_data(html_tree, next_btn, [])

    Enum.map(data_rows, fn l ->
      [head | tail] = l

      [
        head
        |> String.to_integer()
        | tail
      ]
    end)
    |> Enum.map(fn l -> Enum.zip(headers, l) |> Enum.into(%{}) end)
    |> Enum.sort_by(&Map.fetch(&1, "Sorszám"))
    |> Jason.encode!()
  end

  defp get_paginated_data(html_tree, [], acc) do
    acc ++ parse_table_rows(html_tree)
  end

  defp get_paginated_data(html_tree, next_btn, acc) do
    n_page = Floki.attribute(next_btn, "href") |> Floki.text()
    h_tree = parse_response_body("#{@base_url}#{n_page}")
    nbtn = next_button_element(h_tree)

    get_paginated_data(h_tree, nbtn, acc ++ parse_table_rows(html_tree))
  end

  defp parse_table_rows(html_tree) do
    html_tree
    |> Floki.find("tbody")
    |> Floki.find("tr")
    |> Enum.map(fn t ->
      for t2 <- elem(t, 2), do: get_text_from(t2)
    end)
  end

  defp parse_headers(html_tree) do
    html_tree
    |> Floki.find("thead")
    |> Floki.find("th")
    |> Enum.map(fn t ->
      [head | _tail] = elem(t, 2)
      String.trim(head)
    end)
  end

  defp get_text_from(tuple) do
    [head | _tail] = elem(tuple, 2)
    String.trim(head)
  end

  defp make_request(url) do
    {:ok, response} = HTTPoison.get(url)
    response
  end

  defp next_button_element(html_tree) do
    html_tree
    |> Floki.find(".pagination")
    |> Floki.find(".next")
    |> Floki.find("a")
  end

  defp parse_response_body(url) do
    resp = make_request(url)
    {:ok, html_tree} = Floki.parse_document(resp.body)
    html_tree
  end
end
