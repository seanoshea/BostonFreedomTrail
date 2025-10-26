/*
 Copyright (c) 2014 - 2016 Upwards Northwards Software Limited
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 3. All advertising materials mentioning features or use of this software
 must display the following acknowledgement:
 This product includes software developed by Upwards Northwards Software Limited.
 4. Neither the name of Upwards Northwards Software Limited nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY UPWARDS NORTHWARDS SOFTWARE LIMITED ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL UPWARDS NORTHWARDS SOFTWARE LIMITED BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>

#import "BPLLabel.h"

/**
 * @brief Custom info window view for displaying placemark information on the map
 * 
 * BPLInfoWindow provides a customized info window that appears when users tap on
 * map markers. It displays the placemark name and additional information in a
 * styled container view.
 * 
 * @author Upwards Northwards Software Limited
 * @since 1.0
 * 
 * Usage:
 * @code
 * BPLInfoWindow *infoWindow = [[BPLInfoWindow alloc] init];
 * infoWindow.header.text = @"Placemark Name";
 * infoWindow.runner.text = @"Additional Info";
 * @endcode
 */
@interface BPLInfoWindow : UIView

/**
 * @brief Header label displaying the primary placemark information
 * 
 * This label typically shows the name or title of the Freedom Trail location.
 * Connected via Interface Builder outlet.
 */
@property (nonatomic, weak) IBOutlet BPLLabel *header;

/**
 * @brief Secondary label for additional placemark details
 * 
 * This label can display supplementary information about the location.
 * Connected via Interface Builder outlet.
 */
@property (nonatomic, weak) IBOutlet BPLLabel *runner;

@end
