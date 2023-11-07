defmodule OpenApiSpex.SchemaxTest do
  use ExUnit.Case, async: true
  alias OpenApiSpex.Schema

  defmodule SimpleUser do
    use OpenApiSpex.Schemax

    schema "SimpleUser" do
      property :id, :integer
      property :name, :string
      property :is_verified, :boolean
    end
  end

  defmodule OptionFieldSchema do
    use OpenApiSpex.Schemax

    schema "OptionFieldSchema" do
      property :id, :integer, minimum: 1, maximum: 1000
      property :name, :string, nullable: true
      property :status, :string, enum: ["activated", "deactivated"]
      property :ids, :array, items: :integer
    end
  end

  defmodule AdditionalFieldsSchema do
    use OpenApiSpex.Schemax

    @required [:no_name]
    schema "AdditionalFieldsSchema" do
      property :no_name, :string
      description "this is description"
      read_only true
      nullable true
      additional_properties false
      deprecated true
    end
  end

  defmodule SnakeCaseConvertSchema do
    use OpenApiSpex.Schemax

    schema "SnakeCaseConvertSchema" do
      property :multi, :object, one_of: [SimpleUser, OptionFieldSchema]
    end
  end

  defmodule The.NestedSchema do
    use OpenApiSpex.Schemax

    schema "NestedSchema" do
      property :id, :integer
    end
  end

  defmodule DelayEvalSchema do
    use OpenApiSpex.Schemax
    alias The.NestedSchema

    schema "DelayEvalSchema" do
      property :id, :integer
      property :list, :array, items: NestedSchema
      example example()
    end

    defp example do
      %{
        id: 1
      }
    end
  end

  defmodule EmbeddedParentSchema do
    use OpenApiSpex.Schemax

    schema "EmbeddedParentSchema" do
      property :children, :array, items: child()
    end

    embedded_schema :child do
      property :id, :integer
      property :name, :string
      required [:id, :name]
    end

    embedded_schema :child2 do
      schema_type :string
    end
  end

  defmodule OtherTypeSchema do
    use OpenApiSpex.Schemax

    @schema_type :array
    schema "OtherTypeSchema" do
      items :integer
    end
  end

  defmodule OtherTypeSchema2 do
    use OpenApiSpex.Schemax

    @schema_type :array
    schema "OtherTypeSchema" do
      items SimpleUser
    end
  end

  defmodule NoTitleSchema do
    use OpenApiSpex.Schemax

    schema do
      property :id, :integer
    end
  end

  describe "validate basic schema creation from macro" do
    test "it generates `schema/0` function." do
      assert function_exported?(SimpleUser, :schema, 0)
    end

    test "`schema/0` function returns `OpenApiSpex.Schema` struct. There is a corresponding value in the `title` field" do
      assert %Schema{title: "SimpleUser"} = SimpleUser.schema()
    end

    test "basic validation for generated properties" do
      expected_properties =
        for {field, type} <- [id: :integer, name: :string, is_verified: :boolean],
            into: %{} do
          {field, %Schema{type: type}}
        end

      assert %Schema{properties: ^expected_properties} = SimpleUser.schema()
    end

    test "Each property options must be applied" do
      schema = OptionFieldSchema.schema()
      assert %Schema{type: :integer, minimum: 1, maximum: 1000} = schema.properties.id
      assert %Schema{type: :string, nullable: true} = schema.properties.name
      assert %Schema{type: :string, enum: ["activated", "deactivated"]} = schema.properties.status
    end

    test "`:array` type property requires `items`, so it automatically maps to schema when `:integer`, `:string` type come in `items` field." do
      schema = OptionFieldSchema.schema()
      assert %Schema{type: :array, items: %Schema{type: :integer}} = schema.properties.ids
    end

    test "property option also converts snake_case to camelCase." do
      schema = SnakeCaseConvertSchema.schema()

      assert %Schema{properties: %{multi: %Schema{oneOf: [SimpleUser, OptionFieldSchema]}}} =
               schema
    end

    test "it generates title when doesn't given title argument" do
      schema = NoTitleSchema.schema()
      assert %Schema{title: "NoTitleSchema"} = schema
    end
  end

  describe "validation for additional fields" do
    test "Fields other than property are applied" do
      schema = AdditionalFieldsSchema.schema()

      assert %Schema{
               required: [:no_name],
               description: "this is description",
               readOnly: true,
               nullable: true,
               additionalProperties: false,
               deprecated: true
             } = schema
    end

    test "it can declare non-object types for schema" do
      schema = OtherTypeSchema.schema()

      assert %Schema{type: :array, items: %Schema{type: :integer}} = schema

      schema = OtherTypeSchema2.schema()

      assert %Schema{type: :array, items: SimpleUser} = schema
    end
  end

  describe "Validation for delayed evaluation" do
    test "when you put a function in a property value, the result of the function is put into the property" do
      assert %Schema{example: %{id: 1}} = DelayEvalSchema.schema()
    end

    test "`alias` should be kept across conversion" do
      assert %Schema{properties: %{list: %Schema{type: :array, items: The.NestedSchema}}} =
               DelayEvalSchema.schema()
    end
  end

  describe "`embedded_schema/2`" do
    test "it declares a function with the name given to that module. The function returns a Schema struct, just as the `schema/2` macro does" do
      assert %Schema{} = EmbeddedParentSchema.child()
    end

    test "`title` is nil, `type` is :object. it declares `required` inside" do
      assert %Schema{title: nil, type: :object, required: [:id, :name]} =
               EmbeddedParentSchema.child()
    end

    test "can define `schema_type` inside" do
      assert %Schema{type: :string} = EmbeddedParentSchema.child2()
    end

    test "You can use the function inside of the parent schema" do
      assert %Schema{properties: %{children: %Schema{type: :array, items: child_schema}}} =
               EmbeddedParentSchema.schema()

      assert child_schema == EmbeddedParentSchema.child()
    end
  end
end
