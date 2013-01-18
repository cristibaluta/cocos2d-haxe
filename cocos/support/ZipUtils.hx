/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 *
 * Inflates either zlib or gzip deflated memory. The inflated memory is
 * expected to be freed by the caller.
 *
 * inflateMemory_ based on zlib example code
 *		http://www.zlib.net
 *
 * Some ideas were taken from:
 *		http://themanaworld.org/
 *		from the mapreader.cpp file 
 */

#import <Availability.h>

#import <zlib.h>
#import <stdlib.h>
#import <assert.h>
#import <stdio.h>

import ZipUtils;
import cocos.CCFileUtils;
import ../ccMacros;

// memory in iPhone is precious
// Should buffer factor be 1.5 instead of 2 ?
#define BUFFER_INC_FACTOR (2)

static int inflateMemoryWithHint(char *in, int inLength, char **out, int *outLength, int outLenghtHint )
{
	/* ret value */
	var err :Int = Z_OK;
	
	var bufferSize :Int = outLenghtHint;
	*out = (char*) malloc(bufferSize);
	
    z_stream d_stream; /* decompression stream */	
    d_stream.zalloc = (alloc_func)0;
    d_stream.zfree = (free_func)0;
    d_stream.opaque = (voidpf)0;
	
    d_stream.next_in  = in;
    d_stream.avail_in = inLength;
	d_stream.next_out = *out;
	d_stream.avail_out = bufferSize;
	
	/* window size to hold 256k */
	if( (err = inflateInit2(&d_stream, 15 + 32)) != Z_OK )
		return err;
	
    for (;) {
        err = inflate(&d_stream, Z_NO_FLUSH);
        
		if (err == Z_STREAM_END)
			break;
		
		switch (err) {
			case Z_NEED_DICT:
				err = Z_DATA_ERROR;
			case Z_DATA_ERROR:
			case Z_MEM_ERROR:
				inflateEnd(&d_stream);
				return err;
		}
		
		// not enough memory ?
		if (err != Z_STREAM_END) {
			
			var tmp :char = realloc(*out, bufferSize * BUFFER_INC_FACTOR);
			
			/* not enough memory, ouch */
			if (! tmp ) {
				trace("cocos2d: ZipUtils: realloc failed");
				inflateEnd(&d_stream);
				return Z_MEM_ERROR;
			}
			/* only assign to *out if tmp is valid. it's not guaranteed that realloc will reuse the memory */
			*out = tmp;
			
			d_stream.next_out = *out + bufferSize;
			d_stream.avail_out = bufferSize;
			bufferSize *= BUFFER_INC_FACTOR;
		}
    }
	
	
	*outLength = bufferSize - d_stream.avail_out;
    err = inflateEnd(&d_stream);
	return err;
}

int ccInflateMemoryWithHint(char *in, int inLength, char **out, int outLengthHint )
{
	int outLength = 0;
	var err :Int = inflateMemoryWithHint(in, inLength, out, &outLength, outLengthHint );
	
	if (err != Z_OK || *out == null) {
		if (err == Z_MEM_ERROR)
			trace("cocos2d: ZipUtils: Out of memory while decompressing map data!");
		
		else if (err == Z_VERSION_ERROR)
			trace("cocos2d: ZipUtils: Incompatible zlib version!");
		
		else if (err == Z_DATA_ERROR)
			trace("cocos2d: ZipUtils: Incorrect zlib compressed data!");
		
		else
			trace("cocos2d: ZipUtils: Unknown error while decompressing map data!");
		
		free(*out);
		*out = null;
		outLength = 0;
	}
	
	return outLength;
}

int ccInflateMemory(char *in, int inLength, char **out)
{
	// 256k for hint
	return ccInflateMemoryWithHint(in, inLength, out, 256 * 1024 );
}

int ccInflateGZipFile(const char *path, char **out)
{
	int len;
	int offset = 0;
	
	NSCAssert( out, "ccInflateGZipFile: invalid 'out' parameter");
	NSCAssert( &*out, "ccInflateGZipFile: invalid 'out' parameter");

	var inFile :gzFile = gzopen(path, "rb");
	if( inFile == null ) {
		trace("cocos2d: ZipUtils: error open gzip file: %s", path);
		return -1;
	}
	
	/* 512k initial decompress buffer */
	var bufferSize :Int = 512 * 1024;
	int totalBufferSize = bufferSize;
	
	*out = malloc( bufferSize );
	if( ! out ) {
		trace("cocos2d: ZipUtils: out of memory");
		return -1;
	}
		
	for (;) {
		len = gzread(inFile, *out + offset, bufferSize);
		if (len < 0) {
			trace("cocos2d: ZipUtils: error in gzread");
			free( *out );
			*out = null;
			return -1;
		}
		if (len == 0)
			break;
		
		offset += len;
		
		// finish reading the file
		if( len < bufferSize )
			break;

		bufferSize *= BUFFER_INC_FACTOR;
		totalBufferSize += bufferSize;
		var tmp :char = realloc(*out, totalBufferSize );

		if( ! tmp ) {
			trace("cocos2d: ZipUtils: out of memory");
			free( *out );
			*out = null;
			return -1;
		}
		
		*out = tmp;
	}
			
	if (gzclose(inFile) != Z_OK)
		trace("cocos2d: ZipUtils: gzclose failed");

	return offset;
}

int ccInflateCCZFile(const char *path, char **out)
{
	NSCAssert( out, "ccInflateCCZFile: invalid 'out' parameter");
	NSCAssert( &*out, "ccInflateCCZFile: invalid 'out' parameter");

	// load file into memory
	var compressed :char = null;
	NSInteger fileLen  = ccLoadFileIntoMemory( path, &compressed );
	if( fileLen < 0 ) {
		trace("cocos2d: Error loading CCZ compressed file");
	}
	
	struct var header :CCZHeader = (struct CCZHeader*) compressed;

	// verify header
	if( header.sig[0] != 'C' || header.sig[1] != 'C' || header.sig[2] != 'Z' || header.sig[3] != '!' ) {
		trace("cocos2d: Invalid CCZ file");
		compressed = null;
		return -1;
	}
	
	// verify header version
	var version :uint16_t = CFSwapInt16BigToHost( header.version );
	if( version > 2 ) {
		trace("cocos2d: Unsupported CCZ header format");
		compressed = null;
		return -1;
	}

	// verify compression format
	if( CFSwapInt16BigToHost(header.compression_type) != CCZ_COMPRESSION_ZLIB ) {
		trace("cocos2d: CCZ Unsupported compression method");
		compressed = null;
		return -1;
	}
	
	var len :uint32_t = CFSwapInt32BigToHost( header.len );
	
	*out = malloc( len );
	if(! *out )
	{
		trace("cocos2d: CCZ: Failed to allocate memory for texture");
		compressed = null;
		return -1;
	}
	
	
	var destlen :uLongf = len;
	var source :uLongf = (uLongf) compressed + sizeof(*header);
	var ret :Int = uncompress(*out, &destlen, (Bytef*)source, fileLen - sizeof(*header) );

	free( compressed );
	
	if( ret != Z_OK )
	{
		trace("cocos2d: CCZ: Failed to uncompress data");
		free( *out );
		*out = null;
		return -1;
	}
	
	
	return len;
}
