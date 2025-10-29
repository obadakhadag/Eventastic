/*
Consumer<LanguageProvider>(
builder: (context, languageProvider, child) {
String createEventText = languageProvider.isEnglish
? Localization.en['createEvent']!
    : Localization.ar['createEvent']!;

String eventNameText = languageProvider.isEnglish
? Localization.en['eventName']!
    : Localization.ar['eventName']!;

String descriptionText = languageProvider.isEnglish
? Localization.en['Description']!
    : Localization.ar['Description']!;

String selectStartDateText = languageProvider.isEnglish
? Localization.en['selectStartDate']!
    : Localization.ar['selectStartDate']!;

String selectEndDateText = languageProvider.isEnglish
? Localization.en['selectEndDate']!
    : Localization.ar['selectEndDate']!;

String selectMinimumAgeText = languageProvider.isEnglish
? Localization.en['selectMinimumAge']!
    : Localization.ar['selectMinimumAge']!;

String isPaidText = languageProvider.isEnglish
? Localization.en['isPaid']!
    : Localization.ar['isPaid']!;

String isPrivateText = languageProvider.isEnglish
? Localization.en['isPrivate']!
    : Localization.ar['isPrivate']!;

String nextText = languageProvider.isEnglish
? Localization.en['Next']!
    : Localization.ar['Next']!;

String selectAttendanceTypeText = languageProvider.isEnglish
? Localization.en['selectAttendanceType']!
    : Localization.ar['selectAttendanceType']!;

String invitationText = languageProvider.isEnglish
? Localization.en['Invitation']!
    : Localization.ar['Invitation']!;

String ticketText = languageProvider.isEnglish
? Localization.en['Ticket']!
    : Localization.ar['Ticket']!;

String yourEventTypeText = languageProvider.isEnglish
? Localization.en['yourEventType']!
    : Localization.ar['yourEventType']!;

String cancelCreateEventText = languageProvider.isEnglish
? Localization.en['cancelCreateEvent']!
    : Localization.ar['cancelCreateEvent']!;

String selectText = languageProvider.isEnglish
? Localization.en['Select']!
    : Localization.ar['Select']!;

String venueText = languageProvider.isEnglish
? Localization.en['Venue']!
    : Localization.ar['Venue']!;

String cancelEventText = languageProvider.isEnglish
? Localization.en['cancelEvent']!
    : Localization.ar['cancelEvent']!;

String locationText = languageProvider.isEnglish
? Localization.en['Location']!
    : Localization.ar['Location']!;

String maxCapacityText = languageProvider.isEnglish
? Localization.en['maxCapacity']!
    : Localization.ar['maxCapacity']!;

String ratingText = languageProvider.isEnglish
? Localization.en['Rating']!
    : Localization.ar['Rating']!;

String priceText = languageProvider.isEnglish
? Localization.en['Price']!
    : Localization.ar['Price']!;

String locationOnMapText = languageProvider.isEnglish
? Localization.en['locationOnMap']!
    : Localization.ar['locationOnMap']!;

String maxCapacityWithChairsText = languageProvider.isEnglish
? Localization.en['maxCapacityWithChairs']!
    : Localization.ar['maxCapacityWithChairs']!;

String chairsText = languageProvider.isEnglish
? Localization.en['Chairs']!
    : Localization.ar['Chairs']!;

String vipChairsText = languageProvider.isEnglish
? Localization.en['vipChairs']!
    : Localization.ar['vipChairs']!;

String vipText = languageProvider.isEnglish
? Localization.en['Vip']!
    : Localization.ar['Vip']!;

String closeText = languageProvider.isEnglish
? Localization.en['Close']!
    : Localization.ar['Close']!;

String chooseFurnitureText = languageProvider.isEnglish
? Localization.en['chooseFurniture']!
    : Localization.ar['chooseFurniture']!;

String nameText = languageProvider.isEnglish
? Localization.en['Name']!
    : Localization.ar['Name']!;

String quantityInWarehouseText = languageProvider.isEnglish
? Localization.en['quantityInWarehouse']!
    : Localization.ar['quantityInWarehouse']!;

String costText = languageProvider.isEnglish
? Localization.en['Cost']!
    : Localization.ar['Cost']!;

String chooseText = languageProvider.isEnglish
? Localization.en['Choose']!
    : Localization.ar['Choose']!;

String decorationCategoryText = languageProvider.isEnglish
? Localization.en['decorationCategory']!
    : Localization.ar['decorationCategory']!;

String availableText = languageProvider.isEnglish
? Localization.en['Available']!
    : Localization.ar['Available']!;

String quantityText = languageProvider.isEnglish
? Localization.en['Quantity']!
    : Localization.ar['Quantity']!;

String toOrderPressPlusText = languageProvider.isEnglish
? Localization.en['toOrder,press+']!
    : Localization.ar['toOrder,press+']!;

String orderText = languageProvider.isEnglish
? Localization.en['Order']!
    : Localization.ar['Order']!;

String soundSelectionText = languageProvider.isEnglish
? Localization.en['soundSelection']!
    : Localization.ar['soundSelection']!;

String genreText = languageProvider.isEnglish
? Localization.en['Genre']!
    : Localization.ar['Genre']!;

String reserveText = languageProvider.isEnglish
? Localization.en['Reserve']!
    : Localization.ar['Reserve']!;

String securityText = languageProvider.isEnglish
? Localization.en['Security']!
    : Localization.ar['Security']!;

String securitySettingsText = languageProvider.isEnglish
? Localization.en['securitySettings']!
    : Localization.ar['securitySettings']!;

String costPerGuardText = languageProvider.isEnglish
? Localization.en['costPerGuard']!
    : Localization.ar['costPerGuard']!;

String foodText = languageProvider.isEnglish
? Localization.en['Food']!
    : Localization.ar['Food']!;

String selectServingDateText = languageProvider.isEnglish
? Localization.en['selectServingDate']!
    : Localization.ar['selectServingDate']!;

String drinkMenuText = languageProvider.isEnglish
? Localization.en['drinkMenu']!
    : Localization.ar['drinkMenu']!;

String ageRequiredText = languageProvider.isEnglish
? Localization.en['age_required']!
    : Localization.ar['age_required']!;

String submitText = languageProvider.isEnglish
? Localization.en['Submit']!
    : Localization.ar['Submit']!;

String thisEventIsNotPaidText = languageProvider.isEnglish
? Localization.en['thisEventIsNotPaid']!
    : Localization.ar['thisEventIsNotPaid']!;

String saveText = languageProvider.isEnglish
? Localization.en['Save']!
    : Localization.ar['Save']!;

String editPriceText = languageProvider.isEnglish
? Localization.en['editPrice']!
    : Localization.ar['editPrice']!;

String totalCostText = languageProvider.isEnglish
? Localization.en['totalCost']!
    : Localization.ar['totalCost']!;

String regularTicketPriceText = languageProvider.isEnglish
? Localization.en['regularTicketPrice']!
    : Localization.ar['regularTicketPrice']!;

String vipTicketPriceText = languageProvider.isEnglish
? Localization.en['vipTicketPrice']!
    : Localization.ar['vipTicketPrice']!;

return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
createEventText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 30,
fontFamily: 'Satisfy',
),
),
Text(
eventNameText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
descriptionText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
selectStartDateText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
selectEndDateText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
selectMinimumAgeText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
isPaidText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
isPrivateText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
nextText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),

),
Text(
selectAttendanceTypeText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
invitationText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
ticketText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
yourEventTypeText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
cancelCreateEventText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
selectText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
venueText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
cancelEventText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
locationText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
maxCapacityText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
ratingText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
priceText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
locationOnMapText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
maxCapacityWithChairsText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
chairsText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
vipChairsText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
vipText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
closeText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
chooseFurnitureText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
nameText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
quantityInWarehouseText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
costText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
chooseText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
decorationCategoryText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
availableText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
quantityText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
toOrderPressPlusText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
orderText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
soundSelectionText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
genreText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
reserveText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
securityText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
securitySettingsText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
costPerGuardText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
foodText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
selectServingDateText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
drinkMenuText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
ageRequiredText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
submitText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
thisEventIsNotPaidText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
saveText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
editPriceText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
totalCostText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
regularTicketPriceText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
Text(
vipTicketPriceText,
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
fontFamily: 'Satisfy',
),
),
],
);
},
),*/
