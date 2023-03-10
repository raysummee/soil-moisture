import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:soil_moisture/features/examine/data/models/examine_ml_model.dart';
import 'package:soil_moisture/features/examine/domain/usecase/examine_ml_usecase.dart';
import 'package:soil_moisture/features/examine/domain/usecase/perc_from_class.dart';

part 'examine_state.dart';

class ExamineCubit extends Cubit<ExamineState> {
  ExamineCubit() : super(ExamineInitial());

  startExamine(File imageFile) async{
    emit(ExamineStarted(imageFile));
    try{
      ExamineMlUseCase examineMlUseCase = ExamineMlUseCase(imageFile);
      List<ExamineMlModel> predictions = await examineMlUseCase();
      predictions.sort((a, b) {
        return b.confidence - a.confidence;
      },);
      var perc = PercFromClass()(predictions);
      emit(ExamineDone(predictions[0], predictions, perc.toDouble()));
    }on Exception catch(err){
      emit(ExamineError(err));
    }
  }
}
