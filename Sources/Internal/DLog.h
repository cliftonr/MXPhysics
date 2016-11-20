#ifndef __DLOG_H__
#define __DLOG_H__

// These macros were written by someone else. See the following URL for more information:
// http://iphoneincubator.com/blog/debugging/the-evolution-of-a-replacement-for-nslog

#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#endif
