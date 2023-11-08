defmodule OpenApiSpex.Schemax do
  @moduledoc """
  Similar to `Ecto.Schema`, define Schema of Open Api Spec as DSL syntax.

  ## `schema` macro

  To define schema, use `schema/2` macro. It must be used once in a module.

  `schema/2` macro define a function named `schema/0`, which return a `%OpenApiSpex.Schema{}` struct.
  The first argument of `schema/2` macro is required and it become `:title` field of the struct.

  ### Example

      defmodule SimpleUser do
        use OpenApiSpex.Schemax

        @required [:id, :name]
        schema "SimpleUser" do
          property :id, :integer
          property :name, :string
          property :is_verified, :boolean
        end
      end

  when you call the created function `schema/0`, it will show:

      iex> SimpleUser.schema()
      %OpenApiSpex.Schema{
        title: "SimpleUser",
        type: :object,
        properties: %{id: %OpenApiSpex.Schema{type: :integer},
        name: %OpenApiSpex.Schema{type: :string},
        is_verified: %OpenApiSpex.Schema{type: :boolean}},
        required: [:id, :name]
      }


  ## `embedded_schema/2` macro

  Unlike `schema/2`, `embedded_schema/2` macro can be defined multiple time in a module.
  Sometimes when you have deep nested schema, it is bothering that turn every schema into modules.
  In that case, you might want to temporary schemas in a module, which you can do through this macro.
  When you define this macro, unlike `schema` macro, put function name into
  first argument of macro instead of title.
  After that, when you want to use that embedded schema, call that function name.

  define both of `:schema_type` and `:required` fields are also included in do block,
  unlike `schema` macro which defines them as module attributes.

  ### Example

      defmodule ListResponse do
        use OpenApiSpex.Schemax

        schema "ListResponse" do
          property :list, list()
        end

        embedded_schema :list do
          property :id, :integer
          property :name, :string
          required [:id, :name]
        end
      end
  """
  alias OpenApiSpex.Schema
  alias OpenApiSpex.Schemax.Parser

  defmacro __using__(_) do
    quote do
      import OpenApiSpex.Schemax, only: [schema: 1, schema: 2, embedded_schema: 2, wrapper: 2]
      alias OpenApiSpex.Schema
      @required []
      @schema_type :object
    end
  end

  @doc """

  """
  defmacro schema(title \\ nil, do: block) do
    fields = Parser.parse_body(block)

    {properties, rest_fields} = extract_properties(fields)

    title =
      if title,
        do: title,
        else: __CALLER__.module |> Module.split() |> List.last()

    quote do
      def schema do
        properties =
          unquote(properties)
          |> Macro.prewalk(&Macro.expand(&1, __ENV__))
          |> Enum.map(fn
            {k, kwlist} when is_list(kwlist) -> {k, struct(Schema, kwlist)}
            other -> other
          end)

        struct(
          Schema,
          [
            title: unquote(title),
            type: @schema_type,
            properties: Map.new(properties),
            required: @required
          ] ++
            unquote(rest_fields)
        )
      end
    end
  end

  defmacro embedded_schema(function_name, do: block) do
    unless is_atom(function_name) do
      raise ArgumentError, "1st argument must be an atom, which represent function name"
    end

    fields = Parser.parse_body(block)

    {properties, rest_fields} = extract_properties(fields)

    quote do
      def unquote(function_name)() do
        properties =
          unquote(properties)
          |> Macro.prewalk(&Macro.expand(&1, __ENV__))
          |> Enum.map(fn
            {k, kwlist} when is_list(kwlist) -> {k, struct(Schema, kwlist)}
            other -> other
          end)

        struct(Schema, [properties: Map.new(properties), type: :object] ++ unquote(rest_fields))
      end
    end
  end

  defp extract_properties(fields) do
    {properties, rest_fields} =
      fields
      |> Enum.split_with(fn
        {:property, _} -> true
        _ -> false
      end)

    properties = build_properties(properties)
    rest_fields = build_rest_fields(rest_fields)

    {properties, rest_fields}
  end

  defp build_properties(properties) do
    properties
    |> Enum.map(fn
      {:property, {name, schema_fields}} when is_list(schema_fields) ->
        {name, schema_fields |> Enum.map(fn {k, v} -> {to_camel_case(k), v} end)}

      {:property, {name, schema_fields, item_type}} ->
        {name,
         [items: item_schema(item_type)] ++
           Enum.map(schema_fields, fn {k, v} -> {to_camel_case(k), v} end)}

      {:property, {name, stuff}} ->
        {name, stuff}
    end)
  end

  defp build_rest_fields(fields) do
    fields
    |> Enum.map(fn
      {:items, s} ->
        {:items, item_schema(s)}

      otherwise ->
        otherwise
    end)
  end

  @known_types [:integer, :string, :boolean, :number, :object]
  defp item_schema(type) when type in @known_types do
    Macro.escape(%Schema{type: type})
  end

  defp item_schema(schema), do: schema

  defp to_camel_case(field) when is_atom(field), do: to_camel_case("#{field}")

  defp to_camel_case(<<f::utf8, _::binary>> = str) do
    <<_::utf8, rest::binary>> = Macro.camelize(str)

    String.to_existing_atom(<<f::utf8, rest::binary>>)
  end

  @doc """
  Wrapper function for convenient.
  For example, if there is a User schema, it can make a response like `%{"user" => %User{...}}`.

  NOTE: This is not recommended. please use `embedded_schema/2` instead.
  """
  @spec wrapper(module() | struct(), atom()) :: Schema.t()
  def wrapper(schema, field_name) when is_atom(field_name) do
    %Schema{
      type: :object,
      properties: %{field_name => schema},
      required: [field_name]
    }
  end
end
