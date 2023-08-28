defmodule Identicon do
   @moduledoc """
    Draw an identicon and save this to a PNG

  ## Examples

    iex> Identicon.main("asdf")
      :ok
  """
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

  @doc """
  This method converts the input to md5 hash and return the object of Struct Image
  whose hex value is array of 16 element

  ## Parameters

    - name: String that represents the name of the user.

  """

  def hash_input(input) do
    hex = :crypto.hash(:md5,input)
      |> :binary.bin_to_list
    %Identicon.Image{hex: hex}
  end

  @doc """
  This method takes first 3 elements of hex param of the object of Struct Image and then converts
  it into color of RGB

  ## Parameters

    - image: Object of type Struct Image.

  """
  def pick_color(%Identicon.Image{hex: [r,g,b | _tail]} = image) do
    %Identicon.Image{image | color: {r,g,b}}
  end

  @doc """
  This method takes  hex param of the object of Struct Image and then converts
  it into chunk of 3 elements and them mirror each of them with index and then
  assigns it to grid of image object after flattening it.

  ## Parameters

    - image: Object of type Struct Image.

  """

  def build_grid(%Identicon.Image{hex: hex_value} = image) do
    grid_value =
      hex_value
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index
     %Identicon.Image{image | grid: grid_value}
  end

  @doc """
  This method accepts array of 3 elements and then mirror it.

  ## Parameters

    - row: Array with 3 element.

  """

  def mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end


  @doc """
  This method accepts image and then removes all the odd value from it and then
  return new object with updated value.

  ## Parameters

    - image: Object of type Struct Image.

  """

  def filter_odd_squares(%Identicon.Image{grid: grid_value} = image) do
    updated_grid_value = Enum.filter grid_value, fn({code, _index})  ->
      rem(code,2) == 0
    end
    %Identicon.Image{image | grid: updated_grid_value}
  end

  @doc """
  This method accepts image and then build pixel map for each filled value and then
  return new object with updated value.

  ## Parameters

    - image: Object of type Struct Image.

  """

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

  @doc """
  This method accepts color and pixel, then render the actual Identicon using EGD dependency.
  We need to install is explicitely by declaring it inside `mix.exs` file.

  More info : https://www.erlang.org/docs/17/man/egd

  ## Parameters

    - color: color from Struct Image.
    - pixel: pixel from Struct Image.

  """

  def draw_image(%Identicon.Image{color: color, pixel: pixel}) do
    image = :egd.create(250,250)
    fill = :egd.color(color)

    Enum.each  pixel, fn({start, stop})  ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  @doc """
  This method accepts image and input, then saves it into current folder.

  ## Parameters

    - image: actual image file.
    - input: file name (name of user).

  """
  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end
