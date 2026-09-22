import 'package:flutter/material.dart';
import 'package:ecommerce/features/address/domain/models/address_model.dart';
import 'package:ecommerce/interfaces/repository_interface.dart';

abstract class LanguageRepositoryInterface extends RepositoryInterface {
  AddressModel? getAddressFormSharedPref();
  void updateHeader(AddressModel? addressModel, Locale locale, int? moduleId);
  Locale getLocaleFromSharedPref();
  void saveLanguage(Locale locale);
}