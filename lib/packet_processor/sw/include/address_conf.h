// Copyright (C) 2017 Philipp Holzinger
// Copyright (C) 2017 Martin Stumpf
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#ifndef ADDRESS_CONF_H_
#define ADDRESS_CONF_H_

#include "stdint.h"
#include "hsa_packets.h"

#ifndef MAX_QUEUE_LENGTH
#define MAX_QUEUE_LENGTH 128
#endif

// defines to bypass C restrictions which are not present in C++
#define DEF_BASE_HOST_MEMORY            0x0000000000000000
#define DEF_BASE_DEVICE_MEMORY          0x0001000000000000
#define DEF_BASE_CONFIG_SPACE           0x0002000000000000
#define DEF_BASE_AQL_PKT_ADDR 		(DEF_BASE_DEVICE_MEMORY + 0x0000000)
#define DEF_BASE_PASID_BUF_ADDR 	(DEF_BASE_DEVICE_MEMORY + (MAX_QUEUE_LENGTH*PACKETSIZE))
#define DEF_READ_INDEX 			(DEF_BASE_DEVICE_MEMORY + (MAX_QUEUE_LENGTH*PACKETSIZE)+(MAX_QUEUE_LENGTH*4))
#define DEF_WRITE_INDEX 		(DEF_BASE_DEVICE_MEMORY + (MAX_QUEUE_LENGTH*PACKETSIZE)+(MAX_QUEUE_LENGTH*4)+8)
#define DEF_BASE_FREE_MEM 		(DEF_BASE_DEVICE_MEMORY + (MAX_QUEUE_LENGTH*PACKETSIZE)+(MAX_QUEUE_LENGTH*4)+16)
#define DEF_AQL_LEFT 			(DEF_BASE_CONFIG_SPACE + 0x00000)
#define DEF_SND_INT 			(DEF_BASE_CONFIG_SPACE + 0x00008)
#define DEF_RCV_INT_ADDR 		(DEF_BASE_CONFIG_SPACE + 0x00010)
#define DEF_DMA_HOST_ADDR 		(DEF_BASE_CONFIG_SPACE + 0x00050)
#define DEF_DMA_DEVICE_ADDR 		(DEF_BASE_CONFIG_SPACE + 0x00058)
#define DEF_DMA_PAYLOAD_SIZE_ADDR 	(DEF_BASE_CONFIG_SPACE + 0x00060)
#define DEF_DMA_LDST_ADDR 		(DEF_BASE_CONFIG_SPACE + 0x00068)
#define DEF_DMA_PASID_ADDR 		(DEF_BASE_CONFIG_SPACE + 0x0006C)
#define DEF_CMPL_SIG_ADDR 		(DEF_BASE_CONFIG_SPACE + 0x00080)
#define DEF_CMPL_SIG_PASID_ADDR 	(DEF_BASE_CONFIG_SPACE + 0x00088)
#define DEF_BASE_ACCEL_ADDR 		(DEF_BASE_CONFIG_SPACE + 0x01000)

//------------------

// base addresses of the three memory segments
volatile uint64_t * const BASE_HOST_MEMORY   = (volatile uint64_t * const) DEF_BASE_HOST_MEMORY;
volatile uint64_t * const BASE_DEVICE_MEMORY = (volatile uint64_t * const) DEF_BASE_DEVICE_MEMORY;
volatile uint64_t * const BASE_CONFIG_SPACE  = (volatile uint64_t * const) DEF_BASE_CONFIG_SPACE;

// device memory addresses
const volatile uint64_t * const BASE_AQL_PKT_ADDR   = (const volatile uint64_t * const)DEF_BASE_AQL_PKT_ADDR;
const volatile uint32_t * const BASE_PASID_BUF_ADDR = (const volatile uint32_t * const)DEF_BASE_PASID_BUF_ADDR;
volatile uint64_t * const READ_INDEX                = (volatile uint64_t * const)      DEF_READ_INDEX;
const volatile uint64_t * const WRITE_INDEX         = (const volatile uint64_t * const)DEF_WRITE_INDEX;
volatile uint64_t * const BASE_FREE_MEM             = (volatile uint64_t * const)      DEF_BASE_FREE_MEM;

// interrupt addresses (from/to interrupt controller)
volatile uint64_t * const AQL_LEFT           = (volatile uint64_t * const)      DEF_AQL_LEFT;
volatile uint64_t * const SND_INT            = (volatile uint64_t * const)      DEF_SND_INT;
const volatile uint64_t * const RCV_INT_ADDR = (const volatile uint64_t * const)DEF_RCV_INT_ADDR;

// DMA register addresses
volatile uint64_t * const DMA_HOST_ADDR         = (volatile uint64_t * const)DEF_DMA_HOST_ADDR;
volatile uint64_t * const DMA_DEVICE_ADDR       = (volatile uint64_t * const)DEF_DMA_DEVICE_ADDR;
volatile uint64_t * const DMA_PAYLOAD_SIZE_ADDR = (volatile uint64_t * const)DEF_DMA_PAYLOAD_SIZE_ADDR;
volatile uint32_t * const DMA_LDST_ADDR         = (volatile uint32_t * const)DEF_DMA_LDST_ADDR;
volatile uint32_t * const DMA_PASID_ADDR        = (volatile uint32_t * const)DEF_DMA_PASID_ADDR;

// completion signal addresse
volatile uint64_t * const CMPL_SIG_ADDR       = (volatile uint64_t * const)DEF_CMPL_SIG_ADDR;
volatile uint32_t * const CMPL_SIG_PASID_ADDR = (volatile uint32_t * const)DEF_CMPL_SIG_PASID_ADDR;

// image processing config addresses
volatile char * const BASE_ACCEL_ADDR = (volatile char * const)DEF_BASE_ACCEL_ADDR;
const uint32_t ACCEL_ADDR_SPACE_LEN   = (const uint32_t) 0x01000;

const uint16_t TASK_OFFSET            = (const uint16_t) 0x00000;
const uint16_t NORMALIZATION_OFFSET   = (const uint16_t) 0x00002;
const uint16_t THRESHOLD_OFFSET       = (const uint16_t) 0x00004;
const  uint8_t COLOR_MODEL_OFFSET     = (const uint8_t ) 0x00006;
const  uint8_t BORDER_HANDLING_OFFSET = (const uint8_t ) 0x00007;
const uint32_t IMG_WIDTH_OFFSET       = (const uint32_t) 0x00008;
const uint32_t IMG_HEIGHT_OFFSET      = (const uint32_t) 0x0000C;
const uint64_t SRC_ADDR_OFFSET        = (const uint64_t) 0x00010;
const uint64_t DST_ADDR_OFFSET        = (const uint64_t) 0x00018;
const  int32_t MASK0_OFFSET           = (const  int32_t) 0x00020;
const  int32_t MASK1_OFFSET           = (const  int32_t) 0x00084;

#endif
