// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Nonna';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get welcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get hello => 'Hola';

  @override
  String helloUser(String userName) {
    return '¡Hola, $userName!';
  }

  @override
  String get common_ok => 'Aceptar';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_save => 'Guardar';

  @override
  String get common_delete => 'Eliminar';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_add => 'Añadir';

  @override
  String get common_remove => 'Quitar';

  @override
  String get common_close => 'Cerrar';

  @override
  String get common_done => 'Hecho';

  @override
  String get common_continue => 'Continuar';

  @override
  String get common_back => 'Atrás';

  @override
  String get common_next => 'Siguiente';

  @override
  String get common_yes => 'Sí';

  @override
  String get common_no => 'No';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String get common_retry => 'Reintentar';

  @override
  String get common_refresh => 'Actualizar';

  @override
  String get common_loading => 'Cargando...';

  @override
  String get common_search => 'Buscar';

  @override
  String get common_filter => 'Filtrar';

  @override
  String get common_sort => 'Ordenar';

  @override
  String get common_share => 'Compartir';

  @override
  String get common_submit => 'Enviar';

  @override
  String get error_title => 'Error';

  @override
  String get error_generic => 'Algo salió mal. Por favor, inténtalo de nuevo.';

  @override
  String get error_network =>
      'Error de conexión de red. Por favor, verifica tu conexión a internet.';

  @override
  String get error_timeout =>
      'La solicitud ha caducado. Por favor, inténtalo de nuevo.';

  @override
  String get error_server =>
      'Error del servidor. Por favor, inténtalo más tarde.';

  @override
  String get error_unauthorized =>
      'No estás autorizado para realizar esta acción.';

  @override
  String get error_notFound => 'No se encontró el recurso solicitado.';

  @override
  String get error_validation =>
      'Por favor, verifica tu entrada e inténtalo de nuevo.';

  @override
  String get error_required_field => 'Este campo es obligatorio';

  @override
  String get error_invalid_email =>
      'Por favor, ingresa una dirección de correo válida';

  @override
  String get error_invalid_password =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get error_passwords_dont_match => 'Las contraseñas no coinciden';

  @override
  String get empty_state_no_data => 'No hay datos disponibles';

  @override
  String get empty_state_no_results => 'No se encontraron resultados';

  @override
  String get empty_state_no_items => 'Aún no hay elementos';

  @override
  String get empty_state_start_creating =>
      'Comienza creando tu primer elemento';

  @override
  String get empty_state_recipes_title => 'Aún No Hay Recetas';

  @override
  String get empty_state_recipes_message =>
      'Comienza a construir tu colección de recetas';

  @override
  String get empty_state_recipes_action => 'Añadir Receta';

  @override
  String get empty_state_favorites_title => 'Sin Favoritos';

  @override
  String get empty_state_favorites_message =>
      'Las recetas que marques como favoritas aparecerán aquí';

  @override
  String get nav_home => 'Inicio';

  @override
  String get nav_recipes => 'Recetas';

  @override
  String get nav_favorites => 'Favoritos';

  @override
  String get nav_profile => 'Perfil';

  @override
  String get nav_settings => 'Configuración';

  @override
  String get auth_login => 'Iniciar Sesión';

  @override
  String get auth_logout => 'Cerrar Sesión';

  @override
  String get auth_signup => 'Registrarse';

  @override
  String get auth_email => 'Correo Electrónico';

  @override
  String get auth_password => 'Contraseña';

  @override
  String get auth_confirm_password => 'Confirmar Contraseña';

  @override
  String get auth_forgot_password => '¿Olvidaste tu Contraseña?';

  @override
  String get auth_reset_password => 'Restablecer Contraseña';

  @override
  String get auth_create_account => 'Crear Cuenta';

  @override
  String get auth_already_have_account => '¿Ya tienes una cuenta?';

  @override
  String get auth_dont_have_account => '¿No tienes una cuenta?';

  @override
  String get auth_or_continue_with => 'O continúa con';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_notifications => 'Notificaciones';

  @override
  String get settings_privacy => 'Privacidad';

  @override
  String get settings_about => 'Acerca de';

  @override
  String get settings_help => 'Ayuda y Soporte';

  @override
  String get settings_terms => 'Términos de Servicio';

  @override
  String get settings_privacy_policy => 'Política de Privacidad';

  @override
  String get recipe_title => 'Receta';

  @override
  String get recipe_ingredients => 'Ingredientes';

  @override
  String get recipe_instructions => 'Instrucciones';

  @override
  String get recipe_prep_time => 'Tiempo de Preparación';

  @override
  String get recipe_cook_time => 'Tiempo de Cocción';

  @override
  String get recipe_servings => 'Porciones';

  @override
  String get recipe_difficulty => 'Dificultad';

  @override
  String get recipe_difficulty_easy => 'Fácil';

  @override
  String get recipe_difficulty_medium => 'Media';

  @override
  String get recipe_difficulty_hard => 'Difícil';

  @override
  String get recipe_add_to_favorites => 'Añadir a Favoritos';

  @override
  String get recipe_remove_from_favorites => 'Quitar de Favoritos';

  @override
  String plurals_items(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
      zero: 'Sin elementos',
    );
    return '$_temp0';
  }

  @override
  String plurals_recipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recetas',
      one: '1 receta',
      zero: 'Sin recetas',
    );
    return '$_temp0';
  }

  @override
  String plurals_minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String plurals_hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String get date_today => 'Hoy';

  @override
  String get date_yesterday => 'Ayer';

  @override
  String get date_tomorrow => 'Mañana';

  @override
  String get success_saved => 'Guardado exitosamente';

  @override
  String get success_deleted => 'Eliminado exitosamente';

  @override
  String get success_updated => 'Actualizado exitosamente';

  @override
  String get success_added => 'Añadido exitosamente';

  @override
  String get confirm_delete_title => 'Eliminar Elemento';

  @override
  String get confirm_delete_message =>
      '¿Estás seguro de que deseas eliminar este elemento? Esta acción no se puede deshacer.';

  @override
  String get confirm_logout_title => 'Cerrar Sesión';

  @override
  String get confirm_logout_message =>
      '¿Estás seguro de que deseas cerrar sesión?';
}
