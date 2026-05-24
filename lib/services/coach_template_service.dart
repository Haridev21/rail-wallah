// lib/services/coach_template_service.dart

import '../models/coach_config.dart';
import '../constants/train_templates.dart';

class CoachTemplateService {
  static List<CoachConfig> resolve(String trainNo, String trainName) {
    return getCoachTemplate(trainNo, trainName);
  }
}
