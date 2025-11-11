# promille_zone_api.api.HouseholdApi

## Load the API package
```dart
import 'package:promille_zone_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createHousehold**](HouseholdApi.md#createhousehold) | **POST** /api/household | 
[**createInviteCode**](HouseholdApi.md#createinvitecode) | **POST** /api/household/invite | 
[**joinHousehold**](HouseholdApi.md#joinhousehold) | **POST** /api/household/join | 
[**leaveHousehold**](HouseholdApi.md#leavehousehold) | **DELETE** /api/household/leave | 


# **createHousehold**
> HouseholdResponse createHousehold(createHouseholdRequest)



Create a new household with the authenticated user as the first member. Requires name, address, and household type (family, dorm, or other).

### Example
```dart
import 'package:promille_zone_api/api.dart';

final api = PromilleZoneApi().getHouseholdApi();
final CreateHouseholdRequest createHouseholdRequest = ; // CreateHouseholdRequest | 

try {
    final response = api.createHousehold(createHouseholdRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling HouseholdApi->createHousehold: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createHouseholdRequest** | [**CreateHouseholdRequest**](CreateHouseholdRequest.md)|  | 

### Return type

[**HouseholdResponse**](HouseholdResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createInviteCode**
> InviteCodeResponse createInviteCode()



Generate a 6-digit numeric invite code for your household. The code expires in 1 hour and can only be used once.

### Example
```dart
import 'package:promille_zone_api/api.dart';

final api = PromilleZoneApi().getHouseholdApi();

try {
    final response = api.createInviteCode();
    print(response);
} on DioException catch (e) {
    print('Exception when calling HouseholdApi->createInviteCode: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**InviteCodeResponse**](InviteCodeResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **joinHousehold**
> HouseholdResponse joinHousehold(joinHouseholdRequest)



Join a household using a 6-digit numeric invite code. The code must be valid and not expired. Users can only be in one household at a time.

### Example
```dart
import 'package:promille_zone_api/api.dart';

final api = PromilleZoneApi().getHouseholdApi();
final JoinHouseholdRequest joinHouseholdRequest = ; // JoinHouseholdRequest | 

try {
    final response = api.joinHousehold(joinHouseholdRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling HouseholdApi->joinHousehold: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **joinHouseholdRequest** | [**JoinHouseholdRequest**](JoinHouseholdRequest.md)|  | 

### Return type

[**HouseholdResponse**](HouseholdResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **leaveHousehold**
> leaveHousehold()



Leave your current household. If you are the last member, the household will be automatically deleted along with any associated invite codes.

### Example
```dart
import 'package:promille_zone_api/api.dart';

final api = PromilleZoneApi().getHouseholdApi();

try {
    api.leaveHousehold();
} on DioException catch (e) {
    print('Exception when calling HouseholdApi->leaveHousehold: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

