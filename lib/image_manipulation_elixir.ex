defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5,input)
      |> :binary.bin_to_list
    %Identicon.Image{hex: hex}
  end

  def pick_color(%Identicon.Image{hex: [r,g,b | _tail]} = image) do
    %Identicon.Image{image | color: {r,g,b}}
  end

  def build_grid(%Identicon.Image{hex: hex_value} = image) do
    grid_value =
      hex_value
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index
     %Identicon.Image{image | grid: grid_value}
  end

  def mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end

  def filter_odd_squares(%Identicon.Image{grid: grid_value} = image) do
    updated_grid_value = Enum.filter grid_value, fn({code, _index})  ->
      rem(code,2) == 0
    end
    %Identicon.Image{image | grid: updated_grid_value}
  end

  def build_pixel_map(%Identicon.Image{grid: grid_value} = image) do
     pixel_map = Enum.map grid_value, fn({_code, index})  ->
      horizontal = rem(index,5) * 50
      vertical = div(index,5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}
      {top_left, bottom_right}
    end
    %Identicon.Image{image | pixel: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel: pixel}) do
    image = :egd.create(250,250)
    fill = :egd.color(color)

    Enum.each  pixel, fn({start, stop})  ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end
