defmodule OpenApiSpex.Schemax.Parser do
  @moduledoc """
  This module is Parser for `OpenApiSpex.Schemax.schema/2` macro.

  In case of `:property`, this module converts camelCase fields
  of `OpenApiSpex.Schema` struct to snake_case fields.

  We will change this module to support more advanced parsing.
  """
  def parse_body({:__block__, _, lines}), do: parse_lines(lines)
  def parse_body(nil), do: parse_lines([])
  def parse_body(line), do: parse_lines([line])

  def parse_lines(lines) do
    Enum.map(lines, &parse_line(&1))
  end

  defp parse_line({:property, meta, [name, type]}) when is_atom(type),
    do: parse_line({:property, meta, [name, type, []]})

  defp parse_line({:property, _, [name, :array, opts]}) do
    items = opts[:items] || raise ArgumentError, "`:array` type must come with `:items` option"
    opts = Keyword.delete(opts, :items)
    {:property, {name, [type: :array] ++ opts, items}}
  end

  defp parse_line({:property, _, [name, type, opts]}) do
    {:property, {name, [type: type] ++ opts}}
  end

  defp parse_line({:property, _, [name, other]}) do
    {:property, {name, other}}
  end

  defp parse_line({:description, _, [description]}) do
    {:description, description}
  end

  defp parse_line({:schema_type, _, [type]}) do
    {:type, type}
  end

  defp parse_line({:read_only, _, [value]}) do
    {:readOnly, value}
  end

  defp parse_line({:additional_properties, _, [v]}) do
    {:additionalProperties, v}
  end

  defp parse_line({:all_of, _, [v]}) do
    {:allOf, v}
  end

  defp parse_line({:one_of, _, [v]}) do
    {:oneOf, v}
  end

  defp parse_line({:any_of, _, [v]}) do
    {:anyOf, v}
  end

  defp parse_line({:multiple_of, _, [v]}) do
    {:multipleOf, v}
  end

  defp parse_line({:max_items, _, [v]}) do
    {:maxItems, v}
  end

  defp parse_line({:min_items, _, [v]}) do
    {:minItems, v}
  end

  defp parse_line({:max_properties, _, [v]}) do
    {:maxProperties, v}
  end

  defp parse_line({:min_properties, _, [v]}) do
    {:minProperties, v}
  end

  defp parse_line({:exclusive_minimum, _, [v]}) do
    {:exclusiveMinimum, v}
  end

  defp parse_line({:exclusive_maximum, _, [v]}) do
    {:exclusiveMaximum, v}
  end

  defp parse_line({:max_length, _, [v]}) do
    {:maxLength, v}
  end

  defp parse_line({:min_length, _, [v]}) do
    {:minLength, v}
  end

  defp parse_line({:unique_items, _, [v]}) do
    {:uniqueItems, v}
  end

  defp parse_line({:external_docs, _, [v]}) do
    {:externalDocs, v}
  end

  defp parse_line({:validate, _, [v]}) do
    {:"x-validate", v}
  end

  defp parse_line({key, _, [value]}) do
    {key, value}
  end

  defp parse_line(other) do
    raise ArgumentError, "unknown field. #{inspect(other)}"
  end
end
