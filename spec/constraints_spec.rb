require 'spec_helper'

describe JsonTableSchema::Constraints do

  let(:field) {
    {
      'name' => 'Name',
      'type' => '',
      'format' => 'default',
      'constraints' => {}
    }
  }

  let(:constraints) { JsonTableSchema::Constraints.new(field, @value) }

  describe JsonTableSchema::Constraints::Required do

    before(:each) do
      field['type'] = 'string'
    end

    it 'handles an empty constraints hash' do
      @value = 'string'
      expect(constraints.validate!).to eq(true)
    end

    it 'handles an empty constraints hash with no value' do
      @value = ''
      expect(constraints.validate!).to eq(true)
    end

    it 'handles a required true constraint with a value' do
      @value = 'string'
      field['constraints']['required'] = true
      expect(constraints.validate!).to eq(true)
    end

    it 'handles a required false constraint with no value' do
      @value = ''
      field['constraints']['required'] = false
      expect(constraints.validate!).to eq(true)
    end
    it 'handles a required false constraint with a value' do
      @value = 'string'
      field['constraints']['required'] = false
      expect(constraints.validate!).to eq(true)
    end

    it 'raises an error for a required true constraint with no value' do
      @value = ''
      field['constraints']['required'] = true
      expect { constraints.validate! }.to raise_error(JsonTableSchema::ConstraintError)
    end

  end

  describe JsonTableSchema::Constraints::MinLength do

    context 'with string type' do

      before(:each) do
        field['type'] = 'string'
        field['constraints']['minLength'] = 5
      end

      it 'handles with a valid value' do
        @value = 'string'
        expect(constraints.validate!).to eq(true)
      end

      it 'handles when the value is equal' do
        field['constraints']['minLength'] = 6
        @value = 'string'
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['minLength'] = 10
        @value = 'string'
        expect { constraints.validate! }.to raise_error(JsonTableSchema::ConstraintError, 'The field `Name` must have a minimum length of 10')
      end

    end

    context 'with array type' do

      before(:each) do
        field['type'] = 'array'
        field['constraints']['minLength'] = 2
        @value = ['a', 'b', 'c']
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles when the value is equal' do
        field['constraints']['minLength'] = 3
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['minLength'] = 10
        expect { constraints.validate! }.to raise_error(JsonTableSchema::ConstraintError, 'The field `Name` must have a minimum length of 10')
      end

    end

    context 'with object type' do

      before(:each) do
        field['type'] = 'object'
        field['constraints']['minLength'] = 2
        @value = {'a' => 1, 'b' => 2, 'c' => 3}
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles when the value is equal' do
        field['constraints']['minLength'] = 3
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['minLength'] = 10
        expect { constraints.validate! }.to raise_error(JsonTableSchema::ConstraintError, 'The field `Name` must have a minimum length of 10')
      end

    end

    it 'raises for an unsupported type' do
      @value = 2
      field['constraints']['minLength'] = 3
      field['type'] = 'integer'
      expect { constraints.validate! }.to raise_error(JsonTableSchema::ConstraintNotSupported, 'The field type `integer` does not support the `minLength` constraint')
    end

  end

  describe JsonTableSchema::Constraints::MaxLength do

    context 'with string type' do

      before(:each) do
        field['type'] = 'string'
        field['constraints']['maxLength'] = 7
      end

      it 'handles with a valid value' do
        @value = 'string'
        expect(constraints.validate!).to eq(true)
      end

      it 'handles when the value is equal' do
        field['constraints']['maxLength'] = 6
        @value = 'string'
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['maxLength'] = 10
        @value = 'stringggggggggggg'
        expect { constraints.validate! }.to raise_error(JsonTableSchema::ConstraintError, 'The field `Name` must have a maximum length of 10')
      end

    end

    context 'with array type' do

      before(:each) do
        field['type'] = 'array'
        field['constraints']['maxLength'] = 4
        @value = ['a', 'b', 'c']
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles when the value is equal' do
        field['constraints']['maxLength'] = 3
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['maxLength'] = 2
        expect { constraints.validate! }.to raise_error(JsonTableSchema::ConstraintError, 'The field `Name` must have a maximum length of 2')
      end

    end

    context 'with object type' do

      before(:each) do
        field['type'] = 'object'
        field['constraints']['maxLength'] = 4
        @value = {'a' => 1, 'b' => 2, 'c' => 3}
      end

      it 'handles with a valid value' do
        expect(constraints.validate!).to eq(true)
      end

      it 'handles when the value is equal' do
        field['constraints']['maxLength'] = 3
        expect(constraints.validate!).to eq(true)
      end

      it 'handles with an invalid value' do
        field['constraints']['maxLength'] = 2
        expect { constraints.validate! }.to raise_error(JsonTableSchema::ConstraintError, 'The field `Name` must have a maximum length of 2')
      end

    end

    it 'raises for an unsupported type' do
      @value = 2
      field['constraints']['maxLength'] = 3
      field['type'] = 'integer'
      expect { constraints.validate! }.to raise_error(JsonTableSchema::ConstraintNotSupported, 'The field type `integer` does not support the `maxLength` constraint')
    end

  end

end

#
# class TestIntegerTypeConstraints_Minimum(ConstraintsBase):
#
#     '''Test `minimum` constraint for IntegerType'''
#
#     def test_constraints_minimum_valid_value(self):
#         value = 12
#         field = self._make_default_field(type='integer',
#                                          constraints={'minimum': 5})
#         _type = types.IntegerType(field)
#
#         self.assertEqual(_type.cast(value), value)
#
#     def test_constraints_minimum_valid_value_equals(self):
#         value = 12
#         field = self._make_default_field(type='integer',
#                                          constraints={'minimum': 12})
#         _type = types.IntegerType(field)
#
#         self.assertEqual(_type.cast(value), value)
#
#     def test_constraints_minimum_invalid_value(self):
#         value = 12
#         field = self._make_default_field(type='integer',
#                                          constraints={'minimum': 13})
#         _type = types.IntegerType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The field 'Name' must not be less than 13")
#
#
# class TestDateTypeConstraints_Minimum(ConstraintsBase):
#
#     '''Test `minimum` constraint for DateType'''
#
#     def test_constraints_minimum_valid_value(self):
#         value = '1978-05-29'
#         field = self._make_default_field(type='date',
#                                          constraints={'minimum': '1978-05-28'})
#         _type = types.DateType(field)
#
#         self.assertEqual(_type.cast(value),
#                          datetime.datetime.strptime(value, '%Y-%m-%d').date())
#
#     def test_constraints_minimum_valid_value_equals(self):
#         value = '1978-05-29'
#         field = self._make_default_field(type='date',
#                                          constraints={'minimum': '1978-05-29'})
#         _type = types.DateType(field)
#
#         self.assertEqual(_type.cast(value),
#                          datetime.datetime.strptime(value, '%Y-%m-%d').date())
#
#     def test_constraints_minimum_invalid_value(self):
#         value = '1978-05-29'
#         field = self._make_default_field(type='date',
#                                          constraints={'minimum': '1978-05-30'})
#         _type = types.DateType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The field 'Name' must not be less than 1978-05-30")
#
#
# class TestDateTimeTypeConstraints_Minimum(ConstraintsBase):
#
#     '''Test `minimum` constraint for DateTimeType'''
#
#     def test_constraints_minimum_valid_value(self):
#         value = '1978-05-29T12:30:20Z'
#         field = self._make_default_field(type='datetime',
#                                          constraints={'minimum':
#                                                       '1978-05-28T12:30:20Z'})
#         _type = types.DateTimeType(field)
#
#         self.assertEqual(_type.cast(value),
#                          datetime.datetime.strptime(
#                             value, '%Y-%m-%dT%H:%M:%SZ'))
#
#     def test_constraints_minimum_valid_value_equals(self):
#         value = '1978-05-29T12:30:20Z'
#         field = self._make_default_field(type='datetime',
#                                          constraints={'minimum':
#                                                       '1978-05-29T12:30:20Z'})
#         _type = types.DateTimeType(field)
#
#         self.assertEqual(_type.cast(value),
#                          datetime.datetime.strptime(
#                             value, '%Y-%m-%dT%H:%M:%SZ'))
#
#     def test_constraints_minimum_invalid_value(self):
#         value = '1978-05-29T12:30:20Z'
#         field = self._make_default_field(type='datetime',
#                                          constraints={'minimum':
#                                                       '1978-05-30T12:30:20Z'})
#         _type = types.DateTimeType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The field 'Name' must not be less than "
#                          "1978-05-30 12:30:20")
#
#
# class TestTimeTypeConstraints_Minimum(ConstraintsBase):
#
#     '''Test `minimum` constraint for TimeType'''
#
#     def test_constraints_minimum_valid_value(self):
#         value = '12:30:20'
#         field = self._make_default_field(type='time',
#                                          constraints={'minimum': '11:30:20'})
#         _type = types.TimeType(field)
#
#         struct_time = time.strptime(value, '%H:%M:%S')
#         expected_time = datetime.time(struct_time.tm_hour, struct_time.tm_min,
#                                       struct_time.tm_sec)
#         self.assertEqual(_type.cast(value), expected_time)
#
#     def test_constraints_minimum_valid_value_equals(self):
#         value = '12:30:20'
#         field = self._make_default_field(type='time',
#                                          constraints={'minimum': '12:30:20'})
#         _type = types.TimeType(field)
#
#         struct_time = time.strptime(value, '%H:%M:%S')
#         expected_time = datetime.time(struct_time.tm_hour, struct_time.tm_min,
#                                       struct_time.tm_sec)
#         self.assertEqual(_type.cast(value), expected_time)
#
#     def test_constraints_minimum_invalid_value(self):
#         value = '12:30:20'
#         field = self._make_default_field(type='time',
#                                          constraints={'minimum': '13:30:20'})
#         _type = types.TimeType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The field 'Name' must not be less than 13:30:20")
#
#
# class TestUnsupportedTypeConstraints_Minimum(ConstraintsBase):
#
#     '''Test `minimum` constraint for an unsupported type'''
#
#     def test_constraints_minlength_valid_value(self):
#         '''minimum with unsupported type'''
#         value = 'string'
#         field = self._make_default_field(type='string',
#                                          constraints={'minimum': 2})
#         _type = types.StringType(field)
#
#         with pytest.raises(exceptions.ConstraintNotSupported) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "Field type 'string' does not support "
#                          "the minimum constraint")
#
#
# class TestIntegerTypeConstraints_Maximum(ConstraintsBase):
#
#     '''Test `maximum` constraint for IntegerType'''
#
#     def test_constraints_maximum_valid_value(self):
#         value = 12
#         field = self._make_default_field(type='integer',
#                                          constraints={'maximum': 13})
#         _type = types.IntegerType(field)
#
#         self.assertEqual(_type.cast(value), value)
#
#     def test_constraints_maximum_valid_value_equals(self):
#         value = 12
#         field = self._make_default_field(type='integer',
#                                          constraints={'maximum': 12})
#         _type = types.IntegerType(field)
#
#         self.assertEqual(_type.cast(value), value)
#
#     def test_constraints_maximum_invalid_value(self):
#         value = 12
#         field = self._make_default_field(type='integer',
#                                          constraints={'maximum': 11})
#         _type = types.IntegerType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The field 'Name' must not be more than 11")
#
#
# class TestDateTypeConstraints_Maximum(ConstraintsBase):
#
#     '''Test `maximum` constraint for DateType'''
#
#     def test_constraints_maximum_valid_value(self):
#         value = '1978-05-29'
#         field = self._make_default_field(type='date',
#                                          constraints={'maximum': '1978-05-30'})
#         _type = types.DateType(field)
#
#         self.assertEqual(_type.cast(value),
#                          datetime.datetime.strptime(value, '%Y-%m-%d').date())
#
#     def test_constraints_maximum_valid_value_equals(self):
#         value = '1978-05-29'
#         field = self._make_default_field(type='date',
#                                          constraints={'maximum': '1978-05-29'})
#         _type = types.DateType(field)
#
#         self.assertEqual(_type.cast(value),
#                          datetime.datetime.strptime(value, '%Y-%m-%d').date())
#
#     def test_constraints_maximum_invalid_value(self):
#         value = '1978-05-29'
#         # value of maximum constraint should have the same format
#         field = self._make_default_field(type='date',
#                                          constraints={'maximum':
#                                                       '1978-05-28'})
#         _type = types.DateType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The field 'Name' must not be more than 1978-05-28")
#
#
# class TestDateTimeTypeConstraints_Maximum(ConstraintsBase):
#
#     '''Test `maximum` constraint for DateTimeType'''
#
#     def test_constraints_maximum_valid_value(self):
#         value = '1978-05-29T12:30:20Z'
#         field = self._make_default_field(type='datetime',
#                                          constraints={'maximum':
#                                                       '1978-05-30T12:30:20Z'})
#         _type = types.DateTimeType(field)
#
#         self.assertEqual(_type.cast(value),
#                          datetime.datetime.strptime(
#                             value, '%Y-%m-%dT%H:%M:%SZ'))
#
#     def test_constraints_maximum_valid_value_equals(self):
#         value = '1978-05-29T12:30:20Z'
#         field = self._make_default_field(type='datetime',
#                                          constraints={'maximum':
#                                                       '1978-05-29T12:30:20Z'})
#         _type = types.DateTimeType(field)
#
#         self.assertEqual(_type.cast(value),
#                          datetime.datetime.strptime(
#                             value, '%Y-%m-%dT%H:%M:%SZ'))
#
#     def test_constraints_maximum_invalid_value(self):
#         value = '1978-05-29T12:30:20Z'
#         field = self._make_default_field(type='datetime',
#                                          constraints={'maximum':
#                                                       '1978-05-28T12:30:20Z'})
#         _type = types.DateTimeType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The field 'Name' must not be more than "
#                          "1978-05-28 12:30:20")
#
#
# class TestTimeTypeConstraints_Maximum(ConstraintsBase):
#
#     '''Test `maximum` constraint for TimeType'''
#
#     def test_constraints_maximum_valid_value(self):
#         value = '12:30:20'
#         field = self._make_default_field(type='time',
#                                          constraints={'maximum': '13:30:20'})
#         _type = types.TimeType(field)
#
#         struct_time = time.strptime(value, '%H:%M:%S')
#         expected_time = datetime.time(struct_time.tm_hour, struct_time.tm_min,
#                                       struct_time.tm_sec)
#         self.assertEqual(_type.cast(value), expected_time)
#
#     def test_constraints_maximum_valid_value_equals(self):
#         value = '12:30:20'
#         field = self._make_default_field(type='time',
#                                          constraints={'maximum': '12:30:20'})
#         _type = types.TimeType(field)
#
#         struct_time = time.strptime(value, '%H:%M:%S')
#         expected_time = datetime.time(struct_time.tm_hour, struct_time.tm_min,
#                                       struct_time.tm_sec)
#         self.assertEqual(_type.cast(value), expected_time)
#
#     def test_constraints_maximum_invalid_value(self):
#         value = '12:30:20'
#         field = self._make_default_field(type='time',
#                                          constraints={'maximum': '11:30:20'})
#         _type = types.TimeType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The field 'Name' must not be more than 11:30:20")
#
#
# class TestUnsupportedTypeConstraints_Maximum(ConstraintsBase):
#
#     '''Test `maximum` constraint for an unsupported type'''
#
#     def test_constraints_minlength_valid_value(self):
#         '''maximum with unsupported type'''
#         value = 'string'
#         field = self._make_default_field(type='string',
#                                          constraints={'maximum': 2})
#         _type = types.StringType(field)
#
#         with pytest.raises(exceptions.ConstraintNotSupported) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "Field type 'string' does not support "
#                          "the maximum constraint")
#
#
# class TestStringTypeConstraints_Enum(ConstraintsBase):
#
#     '''Test `enum` constraint for StringType'''
#
#     def test_constraints_enum_valid_value(self):
#         '''value is in enum array'''
#         value = "bob"
#         field = self._make_default_field(
#             type='string', constraints={'enum': ['alice', 'bob', 'chuck']})
#
#         _type = types.StringType(field)
#
#         self.assertEqual(_type.cast(value), value)
#
#     def test_constraints_enum_invalid_value(self):
#         '''value is not in enum array'''
#         value = "fred"
#         field = self._make_default_field(
#             type='string', constraints={'enum': ['alice', 'bob', 'chuck']})
#
#         _type = types.StringType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must be in the enum array")
#
#     def test_constraints_enum_invalid_value_case_sensitive(self):
#         '''value comparison is case sensitive'''
#         value = "Bob"
#         field = self._make_default_field(
#             type='string', constraints={'enum': ['alice', 'bob', 'chuck']})
#
#         _type = types.StringType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must be in the enum array")
#
#
# class TestIntegerTypeConstraints_Enum(ConstraintsBase):
#
#     '''Test `enum` constraint for IntegerType'''
#
#     def test_constraints_enum_valid_value(self):
#         '''value is in enum array'''
#         value = 5
#         field = self._make_default_field(
#             type='integer', constraints={'enum': [1, 3, 5]})
#
#         _type = types.IntegerType(field)
#
#         self.assertEqual(_type.cast(value), value)
#
#     def test_constraints_enum_invalid_value(self):
#         '''value is not in enum array'''
#         value = 2
#         field = self._make_default_field(
#             type='integer', constraints={'enum': [1, 3, 5]})
#
#         _type = types.IntegerType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must be in the enum array")
#
#
# class TestNumberTypeConstraints_Enum(ConstraintsBase):
#
#     '''Test `enum` constraint for NumberType'''
#
#     def test_constraints_enum_valid_value(self):
#         '''value is in enum array'''
#         value = 5
#         field = self._make_default_field(
#             type='number', constraints={'enum': ["1.0", "3.0", "5.0"]})
#
#         _type = types.NumberType(field)
#
#         self.assertEqual(_type.cast(value), value)
#
#     def test_constraints_enum_invalid_value(self):
#         '''value is not in enum array'''
#         value = 2
#         field = self._make_default_field(
#             type='number', constraints={'enum': ["1.0", "3.0", "5.0"]})
#
#         _type = types.NumberType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must be in the enum array")
#
#
# class TestBooleanTypeConstraints_Enum(ConstraintsBase):
#
#     '''Test `enum` constraint for BooleanType'''
#
#     def test_constraints_enum_valid_value(self):
#         '''value is in enum array'''
#         value = 'true'
#         field = self._make_default_field(
#             type='boolean', constraints={'enum': [True, ]})
#
#         _type = types.BooleanType(field)
#
#         self.assertEqual(_type.cast(value), True)
#
#     def test_constraints_enum_invalid_value(self):
#         '''value is not in enum array'''
#         value = 'true'
#         field = self._make_default_field(
#             type='boolean', constraints={'enum': [False, ]})
#
#         _type = types.BooleanType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must be in the enum array")
#
#     def test_constraints_enum_valid_value_alternate_truths(self):
#         '''value is equivalent to possible values in enum array'''
#         value = 'true'
#         field = self._make_default_field(
#             type='boolean', constraints={'enum': ['yes', 'y',
#                                                   't', '1', 1]})
#
#         _type = types.BooleanType(field)
#
#         self.assertEqual(_type.cast(value), True)
#
#
# class TestArrayTypeConstraints_Enum(ConstraintsBase):
#
#     '''Test `enum` constraint for ArrayType'''
#
#     def test_constraints_enum_valid_value(self):
#         '''value is in enum array'''
#         value = ['first', 'second', 'third']
#         field = self._make_default_field(
#             type='array', constraints={'enum': [["first",
#                                                  "second",
#                                                  "third"],
#                                                 ["fred",
#                                                  "alice",
#                                                  "bob"], ]})
#
#         _type = types.ArrayType(field)
#
#         self.assertEqual(_type.cast(value), value)
#
#     def test_constraints_enum_invalid_value(self):
#         '''value is not in enum array'''
#         value = ['first', 'second', 'third']
#         field = self._make_default_field(
#             type='array', constraints={'enum': [["fred",
#                                                  "alice",
#                                                  "bob"], ]})
#
#         _type = types.ArrayType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must be in the enum array")
#
#     def test_constraints_enum_invalid_value_different_order(self):
#         '''value is not in enum array. Same members in each array, but
#         different order.'''
#         value = ['first', 'second', 'third']
#         field = self._make_default_field(
#             type='array', constraints={'enum': [["first",
#                                                  "third",
#                                                  "second"], ]})
#
#         _type = types.ArrayType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must be in the enum array")
#
#
# class TestObjectTypeConstraints_Enum(ConstraintsBase):
#
#     '''Test `enum` constraint for ObjectType'''
#
#     def test_constraints_enum_valid_value(self):
#         '''value is in enum array'''
#         value = {'a': 'first', 'b': 'second', 'c': 'third'}
#         field = self._make_default_field(
#             type='object', constraints={'enum': [{'a': 'first',
#                                                   'b': 'second',
#                                                   'c': 'third'}]})
#
#         _type = types.ObjectType(field)
#
#         self.assertEqual(_type.cast(value), value)
#
#     def test_constraints_enum_invalid_value(self):
#         '''value is not in enum array'''
#         value = {'a': 'first', 'b': 'second', 'c': 'third'}
#         field = self._make_default_field(
#             type='object', constraints={'enum': [{'a': 'fred',
#                                                   'b': 'alice',
#                                                   'c': 'bob'}]})
#
#         _type = types.ObjectType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must be in the enum array")
#
#     def test_constraints_enum_valid_value_different_order(self):
#         '''value is in enum array. Same members in each array, but different
#         order.'''
#         value = {'a': 'first', 'b': 'second', 'c': 'third'}
#         field = self._make_default_field(
#             type='object', constraints={'enum': [{'a': 'first',
#                                                   'c': 'third',
#                                                   'b': 'second'}], })
#
#         _type = types.ObjectType(field)
#
#         self.assertEqual(_type.cast(value), value)
#
#
# class TestDateTypeConstraints_Enum(ConstraintsBase):
#
#     '''Test `enum` constraint for DateType'''
#
#     def test_constraints_enum_valid_value(self):
#         '''value is in enum array'''
#         value = "2015-10-22"
#         field = self._make_default_field(
#             type='date', constraints={'enum': ["2015-10-22"]})
#
#         _type = types.DateType(field)
#
#         self.assertEqual(_type.cast(value),
#                          datetime.datetime.strptime(value, '%Y-%m-%d').date())
#
#     def test_constraints_enum_invalid_value(self):
#         '''value is not in enum array'''
#         value = "2015-10-22"
#         field = self._make_default_field(
#             type='date', constraints={'enum': ["2015-10-23"]})
#
#         _type = types.DateType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must be in the enum array")
#
#
# class TestStringTypeConstraints_Pattern(ConstraintsBase):
#
#     '''Test `pattern` constraint for StringType. Values must match XML Schema
#     style Reg Exp.'''
#
#     def test_constraints_pattern_valid_value(self):
#         '''value is valid for pattern'''
#         value = "078-05-1120"
#         field = self._make_default_field(
#             type='string',
#             constraints={"pattern": "[0-9]{3}-[0-9]{2}-[0-9]{4}"})
#
#         _type = types.StringType(field)
#
#         self.assertEqual(_type.cast(value), value)
#
#     def test_constraints_pattern_invalid_value(self):
#         '''value is invalid for pattern'''
#         value = "078-05-112A"
#         field = self._make_default_field(
#             type='string',
#             constraints={"pattern": "[0-9]{3}-[0-9]{2}-[0-9]{4}"})
#
#         _type = types.StringType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must match the pattern")
#
#
# class TestIntegerTypeConstraints_Pattern(ConstraintsBase):
#
#     '''Test `pattern` constraint for IntegerType. Values must match XML Schema
#     style Reg Exp.'''
#
#     def test_constraints_pattern_valid_value(self):
#         '''value is valid for pattern'''
#         value = 789
#         field = self._make_default_field(
#             type='integer',
#             constraints={"pattern": "[7-9]{3}"})
#
#         _type = types.IntegerType(field)
#
#         self.assertEqual(_type.cast(value), value)
#
#     def test_constraints_pattern_invalid_value(self):
#         '''value is invalid for pattern'''
#         value = 678
#         field = self._make_default_field(
#             type='integer',
#             constraints={"pattern": "[7-9]{3}"})
#
#         _type = types.IntegerType(field)
#
#         # Can't check pattern for already cast value
#         self.assertEqual(_type.cast(value), value)
#
#
# class TestNumberTypeConstraints_Pattern(ConstraintsBase):
#
#     '''Test `pattern` constraint for NumberType. Values must match XML Schema
#     style Reg Exp.'''
#
#     def test_constraints_pattern_valid_value(self):
#         '''value is valid for pattern'''
#         value = '7.123'
#         field = self._make_default_field(
#             type='number',
#             constraints={"pattern": "7.[0-9]{3}"})
#
#         _type = types.NumberType(field)
#
#         self.assertEqual(_type.cast(value), decimal.Decimal(value))
#
#     def test_constraints_pattern_invalid_value(self):
#         '''value is invalid for pattern'''
#         value = '7.12'
#         field = self._make_default_field(
#             type='number',
#             constraints={"pattern": "7.[0-9]{3}"})
#
#         _type = types.NumberType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must match the pattern")
#
#
# class TestArrayTypeConstraints_Pattern(ConstraintsBase):
#
#     '''Test `pattern` constraint for ArrayType. Values must match XML Schema
#     style Reg Exp.'''
#
#     def test_constraints_pattern_valid_value(self):
#         '''value is valid for pattern'''
#         value = '["a", "b", "c"]'
#         field = self._make_default_field(
#             type='array',
#             constraints={"pattern": '\[("[a-c]",?\s?)*\]'})
#
#         _type = types.ArrayType(field)
#
#         self.assertEqual(_type.cast(value), json.loads(value))
#
#     def test_constraints_pattern_invalid_value(self):
#         '''value is invalid for pattern'''
#         value = '["a", "b", "c", "d"]'
#         field = self._make_default_field(
#             type='array',
#             constraints={"pattern": '\[("[a-c]",?\s?)*\]'})
#
#         _type = types.ArrayType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must match the pattern")
#
#
# class TestObjectTypeConstraints_Pattern(ConstraintsBase):
#
#     '''Test `pattern` constraint for ObjectType. Values must match XML Schema
#     style Reg Exp.'''
#
#     def test_constraints_pattern_valid_value(self):
#         '''value is valid for pattern'''
#         value = '{"a":1, "b":2, "c":3}'
#         field = self._make_default_field(
#             type='object',
#             constraints={"pattern": '\{("[a-z]":[0-9],?\s?)*\}'})
#
#         _type = types.ObjectType(field)
#
#         self.assertEqual(_type.cast(value), json.loads(value))
#
#     def test_constraints_pattern_invalid_value(self):
#         '''value is invalid for pattern'''
#         value = '{"a":"fred", "b":2, "c":3}'
#         field = self._make_default_field(
#             type='object',
#             constraints={"pattern": '\{("[a-z]":[0-9],?\s?)*\}'})
#
#         _type = types.ObjectType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must match the pattern")
#
#
# class TestDateTypeConstraints_Pattern(ConstraintsBase):
#
#     '''Test `pattern` constraint for DateType. Values must match XML Schema
#     style Reg Exp.'''
#
#     def test_constraints_pattern_valid_value(self):
#         '''value is valid for pattern'''
#         value = '2015-01-23'
#         field = self._make_default_field(
#             type='date',
#             constraints={"pattern": "2015-[0-9]{2}-[0-9]{2}"})
#
#         _type = types.DateType(field)
#
#         self.assertEqual(_type.cast(value),
#                          datetime.datetime.strptime(value, '%Y-%m-%d').date())
#
#     def test_constraints_pattern_invalid_value(self):
#         '''value is invalid for pattern'''
#         value = '2013-01-23'
#         field = self._make_default_field(
#             type='date',
#             constraints={"pattern": "2015-[0-9]{2}-[0-9]{2}"})
#
#         _type = types.DateType(field)
#
#         with pytest.raises(exceptions.ConstraintError) as e:
#             _type.cast(value)
#         self.assertEqual(
#             e.value.msg, "The value for field 'Name' "
#                          "must match the pattern")
