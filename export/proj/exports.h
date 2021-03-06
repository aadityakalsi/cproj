/*! exports.h */

#ifndef _<PKG>_EXPORTS_H_
#define _<PKG>_EXPORTS_H_

#if defined(USE_<PKG>_STATIC)
#  define <PKG>_API
#elif defined(_WIN32) && !defined(__GCC__)
#  ifdef BUILDING_<PKG>_SHARED
#    define <PKG>_API __declspec(dllexport)
#  else
#    define <PKG>_API __declspec(dllimport)
#  endif
#  ifndef _CRT_SECURE_NO_WARNINGS
#    define _CRT_SECURE_NO_WARNINGS
#  endif
#else
#  ifdef BUILDING_<PKG>_SHARED
#    define <PKG>_API __attribute__ ((visibility ("default")))
#  else
#    define <PKG>_API
#  endif
#endif

#if defined(__cplusplus)
#  define <PKG>_EXTERN_C extern "C"
#  define <PKG>_C_API <PKG>_EXTERN_C <PKG>_API
#else
#  define <PKG>_EXTERN_C
#  define <PKG>_C_API <PKG>_API
#endif

#endif/*_<PKG>_EXPORTS_H_*/
