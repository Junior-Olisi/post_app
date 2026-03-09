class NewAddressDto {
  String street;
  String suite;
  String city;

  NewAddressDto({
    required this.street,
    required this.suite,
    required this.city,
  });

  factory NewAddressDto.empty() => NewAddressDto(
    street: '',
    suite: '',
    city: '',
  );
}
