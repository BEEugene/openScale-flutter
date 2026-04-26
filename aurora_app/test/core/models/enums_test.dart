import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/models/enums.dart';

void main() {
  group('Gender', () {
    test('fromName returns male for "male"', () {
      expect(Gender.fromName('male'), Gender.male);
    });

    test('fromName returns female for "female"', () {
      expect(Gender.fromName('female'), Gender.female);
    });

    test('fromName defaults to male for unknown string', () {
      expect(Gender.fromName('unknown'), Gender.male);
    });

    test('fromName defaults to male for empty string', () {
      expect(Gender.fromName(''), Gender.male);
    });

    test('displayName returns correct string', () {
      expect(Gender.male.displayName, 'Male');
      expect(Gender.female.displayName, 'Female');
    });

    test('values contains exactly two entries', () {
      expect(Gender.values.length, 2);
    });
  });

  group('UnitType', () {
    test('fromName returns correct value for known names', () {
      expect(UnitType.fromName('kg'), UnitType.kg);
      expect(UnitType.fromName('lb'), UnitType.lb);
      expect(UnitType.fromName('st'), UnitType.st);
      expect(UnitType.fromName('percent'), UnitType.percent);
      expect(UnitType.fromName('cm'), UnitType.cm);
      expect(UnitType.fromName('inch'), UnitType.inch);
      expect(UnitType.fromName('kcal'), UnitType.kcal);
      expect(UnitType.fromName('bpm'), UnitType.bpm);
      expect(UnitType.fromName('none'), UnitType.none);
    });

    test('fromName defaults to none for unknown string', () {
      expect(UnitType.fromName('unknown'), UnitType.none);
    });

    test('fromName defaults to none for empty string', () {
      expect(UnitType.fromName(''), UnitType.none);
    });

    group('isWeightUnit', () {
      test('kg is a weight unit', () {
        expect(UnitType.kg.isWeightUnit, true);
      });

      test('lb is a weight unit', () {
        expect(UnitType.lb.isWeightUnit, true);
      });

      test('st is a weight unit', () {
        expect(UnitType.st.isWeightUnit, true);
      });

      test('percent is not a weight unit', () {
        expect(UnitType.percent.isWeightUnit, false);
      });

      test('cm is not a weight unit', () {
        expect(UnitType.cm.isWeightUnit, false);
      });

      test('inch is not a weight unit', () {
        expect(UnitType.inch.isWeightUnit, false);
      });

      test('kcal is not a weight unit', () {
        expect(UnitType.kcal.isWeightUnit, false);
      });

      test('bpm is not a weight unit', () {
        expect(UnitType.bpm.isWeightUnit, false);
      });

      test('none is not a weight unit', () {
        expect(UnitType.none.isWeightUnit, false);
      });
    });

    test('displayName returns correct strings', () {
      expect(UnitType.kg.displayName, 'kg');
      expect(UnitType.lb.displayName, 'lb');
      expect(UnitType.st.displayName, 'st');
      expect(UnitType.percent.displayName, '%');
      expect(UnitType.cm.displayName, 'cm');
      expect(UnitType.inch.displayName, 'in');
      expect(UnitType.kcal.displayName, 'kcal');
      expect(UnitType.bpm.displayName, 'bpm');
      expect(UnitType.none.displayName, '');
    });
  });

  group('ActivityLevel', () {
    test('fromInt returns correct value for 0', () {
      expect(ActivityLevel.fromInt(0), ActivityLevel.sedentary);
    });

    test('fromInt returns correct value for 1', () {
      expect(ActivityLevel.fromInt(1), ActivityLevel.mild);
    });

    test('fromInt returns correct value for 2', () {
      expect(ActivityLevel.fromInt(2), ActivityLevel.moderate);
    });

    test('fromInt returns correct value for 3', () {
      expect(ActivityLevel.fromInt(3), ActivityLevel.heavy);
    });

    test('fromInt returns correct value for 4', () {
      expect(ActivityLevel.fromInt(4), ActivityLevel.extreme);
    });

    test('fromInt defaults to sedentary for unknown value', () {
      expect(ActivityLevel.fromInt(99), ActivityLevel.sedentary);
    });

    test('fromInt defaults to sedentary for negative value', () {
      expect(ActivityLevel.fromInt(-1), ActivityLevel.sedentary);
    });

    test('value property returns correct int', () {
      expect(ActivityLevel.sedentary.value, 0);
      expect(ActivityLevel.mild.value, 1);
      expect(ActivityLevel.moderate.value, 2);
      expect(ActivityLevel.heavy.value, 3);
      expect(ActivityLevel.extreme.value, 4);
    });

    test('values contains exactly five entries', () {
      expect(ActivityLevel.values.length, 5);
    });
  });

  group('InputFieldType', () {
    test('fromName returns correct value for known names', () {
      expect(InputFieldType.fromName('float'), InputFieldType.float);
      expect(InputFieldType.fromName('int'), InputFieldType.int);
      expect(InputFieldType.fromName('text'), InputFieldType.text);
      expect(InputFieldType.fromName('date'), InputFieldType.date);
      expect(InputFieldType.fromName('time'), InputFieldType.time);
      expect(InputFieldType.fromName('user'), InputFieldType.user);
    });

    test('fromName defaults to float for unknown string', () {
      expect(InputFieldType.fromName('unknown'), InputFieldType.float);
    });

    test('fromName defaults to float for empty string', () {
      expect(InputFieldType.fromName(''), InputFieldType.float);
    });

    test('values contains exactly six entries', () {
      expect(InputFieldType.values.length, 6);
    });
  });

  group('MeasurementTypeKey', () {
    group('fromId', () {
      test('returns weight for id 1', () {
        expect(MeasurementTypeKey.fromId(1), MeasurementTypeKey.weight);
      });

      test('returns bmi for id 2', () {
        expect(MeasurementTypeKey.fromId(2), MeasurementTypeKey.bmi);
      });

      test('returns bodyFat for id 3', () {
        expect(MeasurementTypeKey.fromId(3), MeasurementTypeKey.bodyFat);
      });

      test('returns water for id 4', () {
        expect(MeasurementTypeKey.fromId(4), MeasurementTypeKey.water);
      });

      test('returns muscle for id 5', () {
        expect(MeasurementTypeKey.fromId(5), MeasurementTypeKey.muscle);
      });

      test('returns lbm for id 6', () {
        expect(MeasurementTypeKey.fromId(6), MeasurementTypeKey.lbm);
      });

      test('returns bone for id 7', () {
        expect(MeasurementTypeKey.fromId(7), MeasurementTypeKey.bone);
      });

      test('returns waist for id 8', () {
        expect(MeasurementTypeKey.fromId(8), MeasurementTypeKey.waist);
      });

      test('returns whr for id 9', () {
        expect(MeasurementTypeKey.fromId(9), MeasurementTypeKey.whr);
      });

      test('returns whtr for id 10', () {
        expect(MeasurementTypeKey.fromId(10), MeasurementTypeKey.whtr);
      });

      test('returns hips for id 11', () {
        expect(MeasurementTypeKey.fromId(11), MeasurementTypeKey.hips);
      });

      test('returns visceralFat for id 12', () {
        expect(MeasurementTypeKey.fromId(12), MeasurementTypeKey.visceralFat);
      });

      test('returns chest for id 13', () {
        expect(MeasurementTypeKey.fromId(13), MeasurementTypeKey.chest);
      });

      test('returns thigh for id 14', () {
        expect(MeasurementTypeKey.fromId(14), MeasurementTypeKey.thigh);
      });

      test('returns biceps for id 15', () {
        expect(MeasurementTypeKey.fromId(15), MeasurementTypeKey.biceps);
      });

      test('returns neck for id 16', () {
        expect(MeasurementTypeKey.fromId(16), MeasurementTypeKey.neck);
      });

      test('returns caliper1 for id 17', () {
        expect(MeasurementTypeKey.fromId(17), MeasurementTypeKey.caliper1);
      });

      test('returns caliper2 for id 18', () {
        expect(MeasurementTypeKey.fromId(18), MeasurementTypeKey.caliper2);
      });

      test('returns caliper3 for id 19', () {
        expect(MeasurementTypeKey.fromId(19), MeasurementTypeKey.caliper3);
      });

      test('returns caliper for id 20', () {
        expect(MeasurementTypeKey.fromId(20), MeasurementTypeKey.caliper);
      });

      test('returns bmr for id 21', () {
        expect(MeasurementTypeKey.fromId(21), MeasurementTypeKey.bmr);
      });

      test('returns tdee for id 22', () {
        expect(MeasurementTypeKey.fromId(22), MeasurementTypeKey.tdee);
      });

      test('returns heartRate for id 23', () {
        expect(MeasurementTypeKey.fromId(23), MeasurementTypeKey.heartRate);
      });

      test('returns calories for id 24', () {
        expect(MeasurementTypeKey.fromId(24), MeasurementTypeKey.calories);
      });

      test('returns date for id 25', () {
        expect(MeasurementTypeKey.fromId(25), MeasurementTypeKey.date);
      });

      test('returns time for id 26', () {
        expect(MeasurementTypeKey.fromId(26), MeasurementTypeKey.time);
      });

      test('returns comment for id 27', () {
        expect(MeasurementTypeKey.fromId(27), MeasurementTypeKey.comment);
      });

      test('returns user for id 28', () {
        expect(MeasurementTypeKey.fromId(28), MeasurementTypeKey.user);
      });

      test('returns custom for id 99', () {
        expect(MeasurementTypeKey.fromId(99), MeasurementTypeKey.custom);
      });

      test('defaults to custom for unknown id', () {
        expect(MeasurementTypeKey.fromId(0), MeasurementTypeKey.custom);
      });
    });

    group('fromName', () {
      test('returns correct enum for known names', () {
        expect(
          MeasurementTypeKey.fromName('weight'),
          MeasurementTypeKey.weight,
        );
        expect(MeasurementTypeKey.fromName('bmi'), MeasurementTypeKey.bmi);
        expect(
          MeasurementTypeKey.fromName('bodyFat'),
          MeasurementTypeKey.bodyFat,
        );
        expect(MeasurementTypeKey.fromName('water'), MeasurementTypeKey.water);
        expect(
          MeasurementTypeKey.fromName('muscle'),
          MeasurementTypeKey.muscle,
        );
      });

      test('defaults to custom for unknown name', () {
        expect(
          MeasurementTypeKey.fromName('nonexistent'),
          MeasurementTypeKey.custom,
        );
      });

      test('defaults to custom for empty string', () {
        expect(MeasurementTypeKey.fromName(''), MeasurementTypeKey.custom);
      });
    });

    group('properties', () {
      test('weight has correct id', () {
        expect(MeasurementTypeKey.weight.id, 1);
      });

      test('custom has correct id', () {
        expect(MeasurementTypeKey.custom.id, 99);
      });

      test('weight allows kg, lb, st units', () {
        expect(MeasurementTypeKey.weight.allowedUnitTypes, [
          UnitType.kg,
          UnitType.lb,
          UnitType.st,
        ]);
      });

      test('weight allows float input type', () {
        expect(MeasurementTypeKey.weight.allowedInputTypes, [
          InputFieldType.float,
        ]);
      });

      test('heartRate allows int input type', () {
        expect(MeasurementTypeKey.heartRate.allowedInputTypes, [
          InputFieldType.int,
        ]);
      });

      test('comment allows text input type', () {
        expect(MeasurementTypeKey.comment.allowedInputTypes, [
          InputFieldType.text,
        ]);
      });
    });
  });
}
