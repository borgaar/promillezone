# promille_zone_api.api.ProfileApi

## Load the API package
```dart
import 'package:promille_zone_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createProfile**](ProfileApi.md#createprofile) | **POST** /api/auth/profile | 
[**getProfile**](ProfileApi.md#getprofile) | **GET** /api/auth/profile | 
[**verifyProfile**](ProfileApi.md#verifyprofile) | **POST** /api/auth/profile/verify | 


# **createProfile**
> ProfileResponse createProfile(createProfileRequest)



Create a profile for the authenticated user. Sends a 6-digit verification code to the user's email address.

### Example
```dart
import 'package:promille_zone_api/api.dart';

final api = PromilleZoneApi().getProfileApi();
final CreateProfileRequest createProfileRequest = ; // CreateProfileRequest | 

try {
    final response = api.createProfile(createProfileRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProfileApi->createProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createProfileRequest** | [**CreateProfileRequest**](CreateProfileRequest.md)|  | 

### Return type

[**ProfileResponse**](ProfileResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getProfile**
> ProfileResponse getProfile()



Get the profile of the authenticated user. Returns the user's profile information if they are verified.

### Example
```dart
import 'package:promille_zone_api/api.dart';

final api = PromilleZoneApi().getProfileApi();

try {
    final response = api.getProfile();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProfileApi->getProfile: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ProfileResponse**](ProfileResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **verifyProfile**
> ProfileResponse verifyProfile(verifyProfileRequest)



Verify the authenticated user's profile using a 6-digit numeric verification code sent to their email. The code expires after a set time period.

### Example
```dart
import 'package:promille_zone_api/api.dart';

final api = PromilleZoneApi().getProfileApi();
final VerifyProfileRequest verifyProfileRequest = ; // VerifyProfileRequest | 

try {
    final response = api.verifyProfile(verifyProfileRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProfileApi->verifyProfile: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **verifyProfileRequest** | [**VerifyProfileRequest**](VerifyProfileRequest.md)|  | 

### Return type

[**ProfileResponse**](ProfileResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

