/*******************************************************************************
* Copyright (C) 2020 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*******************************************************************************/

/*******************************************************************************
  MPLAB Harmony LCDC Generated Driver Implementation File

  File Name:
    drv_gfx_lcdc.c

  Summary:
    Build-time generated implementation for the LCDC Driver for PIC32C MPU/MCUs.

  Description:
    Build-time generated implementation for the LCDC Driver for PIC32C MPU/MCUs.

    Created with MPLAB Harmony Version 3.0
*******************************************************************************/

<#if gfx_hal_le??>

<#assign Val_Width = gfx_hal_le.DisplayWidth>
<#assign Val_Height = gfx_hal_le.DisplayHeight>
<#assign Val_BacklightEnable = gfx_hal_le.DisplayBacklightEnable>
<#assign Val_VSYNCNegative = gfx_hal_le.DisplayVSYNCNegative>
<#assign Val_HSYNCNegative = gfx_hal_le.DisplayHSYNCNegative>
<#assign Val_UseDataEnable = gfx_hal_le.DisplayDataEnable>
<#assign Val_DataEnablePolarity = gfx_hal_le.DisplayDataEnablePolarity>
<#assign Val_HorzFrontPorch = gfx_hal_le.DisplayHorzFrontPorch>
<#assign Val_HorzBackPorch = gfx_hal_le.DisplayHorzBackPorch>
<#assign Val_HorzPulseWidth = gfx_hal_le.DisplayHorzPulseWidth>
<#assign Val_VertFrontPorch = gfx_hal_le.DisplayVertFrontPorch>
<#assign Val_VertBackPorch = gfx_hal_le.DisplayVertBackPorch>
<#assign Val_VertPulseWidth = gfx_hal_le.DisplayVertPulseWidth>

<#else>

<#assign Val_Width = DisplayWidth>
<#assign Val_Height = DisplayHeight>
<#assign Val_BacklightEnable = DisplayBacklightEnable>
<#assign Val_VSYNCNegative = DisplayVSYNCNegative>
<#assign Val_HSYNCNegative = DisplayHSYNCNegative>
<#assign Val_UseDataEnable = DisplayDataEnable>
<#assign Val_DataEnablePolarity = DisplayDataEnablePolarity>
<#assign Val_HorzFrontPorch = DisplayHorzFrontPorch>
<#assign Val_HorzBackPorch = DisplayHorzBackPorch>
<#assign Val_HorzPulseWidth = DisplayHorzPulseWidth>
<#assign Val_VertFrontPorch = DisplayVertFrontPorch>
<#assign Val_VertBackPorch = DisplayVertBackPorch>
<#assign Val_VertPulseWidth = DisplayVertPulseWidth>

</#if>

<#if UseGPU != true>
<#assign VblankBlit = false>
</#if>

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include "gfx/driver/gfx_driver.h"
#include "gfx/driver/controller/lcdc/drv_gfx_lcdc.h"
#include "definitions.h"

// *****************************************************************************
// *****************************************************************************
// Section: Global Data
// *****************************************************************************
// *****************************************************************************

<#if DoubleBuffer == true>
#define BUFFER_PER_LAYER    2
<#else>
#define BUFFER_PER_LAYER    1
</#if>

#define DISPLAY_WIDTH  ${Val_Width}
#define DISPLAY_HEIGHT ${Val_Height}

#define PIXEL_CLOCK_DIV ${PixelClockDiv}
#define LCDC_OUTPUT_COLOR_MODE ${OutputColorMode}
#define LCDC_DISPLAY_GUARD_NUM_FRAMES ${DisplayGuardTime}
#define LCDC_SYNC_EDGE LCDC_SYNC_EDGE_FIRST
#define LCDC_PWM_POLARITY LCDC_POLARITY_POSITIVE
#define GFX_LCDC_BACKGROUND_COLOR 0xffffffff
#define GFX_LCDC_LAYERS ${TotalNumLayers}
#define LCDC_DEFAULT_BRIGHTNESS_PCT ${BacklightBrightnessDefault}

#define SYNC_RECT_COUNT 200

<#if HEOLayerEnable == true>
#define XPHIDEF 0
#define YPHIDEF 0
</#if>

<#if DisplayVSYNCNegative == true>
#define LCDC_VSYNC_POLARITY LCDC_POLARITY_NEGATIVE
<#else>
#define LCDC_VSYNC_POLARITY LCDC_POLARITY_POSITIVE
</#if>

<#if DisplayHSYNCNegative == true>
#define LCDC_HSYNC_POLARITY LCDC_POLARITY_NEGATIVE
<#else>
#define LCDC_HSYNC_POLARITY LCDC_POLARITY_POSITIVE
</#if>

<#if GlobalAlphaEnable == true>
#define LCDC_ENABLE_GLOBAL_HW_ALPHA 1
</#if>

<#if BacklightPWMClockSource == "CLK_MCK">
#define LCDC_PWM_CLOCK_SOURCE LCDC_PWM_SOURCE_SYSTEM
<#else>
#define LCDC_PWM_CLOCK_SOURCE LCDC_PWM_SOURCE_SLOW
</#if>
#define LCDC_PWM_PRESCALER ${BacklightPWMClockPrescaler}

<#if FrameBufferColorMode == "RGB_565">
#define LCDC_DEFAULT_GFX_COLOR_MODE LCDC_INPUT_COLOR_MODE_RGB_565
#define FRAMEBUFFER_PTR_TYPE    uint16_t*
#define FRAMEBUFFER_PIXEL_TYPE    uint16_t
<#elseif FrameBufferColorMode == "RGBA_8888">
#define LCDC_DEFAULT_GFX_COLOR_MODE LCDC_INPUT_COLOR_MODE_RGBA_8888
#define FRAMEBUFFER_PTR_TYPE    uint32_t*
#define FRAMEBUFFER_PIXEL_TYPE    uint32_t
<#else>
//Unsupported  framebuffer type specified, default to RGBA8888
#define LCDC_DEFAULT_GFX_COLOR_MODE LCDC_INPUT_COLOR_MODE_UNSUPPORTED
#define FRAMEBUFFER_PTR_TYPE      uint32_t*
#define FRAMEBUFFER_PIXEL_TYPE    uint32_t
</#if>

typedef enum
{
    LAYER_UNLOCKED,
    LAYER_LOCKED,
    LAYER_LOCKED_PENDING,
} LAYER_LOCK_STATUS;

/**** Hardware Abstraction Interfaces ****/
typedef enum
{
    INIT = 0,
    DRAW,
    SWAP,
    SYNC,
} DRV_STATE;

const char* DRIVER_NAME = "LCDC";

<#if CanvasModeOnly == false>
<#list 0..(TotalNumLayers-1) as i>
FRAMEBUFFER_PIXEL_TYPE  __attribute__ ((section(".region_nocache"), aligned (32))) framebuffer_${i}[DISPLAY_WIDTH * DISPLAY_HEIGHT];
</#list>

<#if DoubleBuffer == true>
<#list 0..(TotalNumLayers-1) as i>
FRAMEBUFFER_PIXEL_TYPE  __attribute__ ((section(".region_nocache"), aligned (32))) framebuffer1_${i}[DISPLAY_WIDTH * DISPLAY_HEIGHT];
</#list>
</#if>
</#if>

typedef struct
{
  uint32_t addr;
  uint32_t ctrl;
  uint32_t next;
} LCDC_DMA_DESC;

<#list 0..(TotalNumLayers-1) as i>
LCDC_DMA_DESC __attribute__ ((section(".region_nocache"), aligned (64))) channelDesc${i};
</#list>

static volatile DRV_STATE state;
<#if UseGPU == true && le_gfx_gfx2d??>
static gfxRect srcRect, destRect;
<#if VblankBlit == true>
volatile gfxPixelBuffer* blitBuff = NULL;
static unsigned int blitLayer = 0;
</#if>
</#if>
static unsigned int vsyncCount = 0;
static unsigned int activeLayer = 0;
<#if DoubleBuffer == true>
static volatile unsigned int syncLayer = 0;
</#if>

static volatile int32_t waitForAlphaSetting[GFX_LCDC_LAYERS] = {0};

//Layer Parameters
//--------------------------------------------------------------------------
typedef struct __display_layer {
    LCDC_LAYER_ID hwLayerID;
    FRAMEBUFFER_PIXEL_TYPE  *baseaddr[BUFFER_PER_LAYER];
    int        draw;
    int        frame;
    uint32_t   resx;
    uint32_t   resy;
    uint32_t   buscfg;
    uint32_t   format;
    int32_t    startx;
    int32_t    starty;
    uint32_t   sizex;
    uint32_t   sizey;
    uint32_t   alpha;
    uint32_t   colorspace;
    uint16_t   color;
    LCDC_DMA_DESC * desc;
    uint32_t frameOffset;
    bool enabled;
    volatile LAYER_LOCK_STATUS updateLock;
    gfxPixelBuffer pixelBuffer[BUFFER_PER_LAYER];
    volatile unsigned int frontBufferIdx;
    volatile unsigned int backBufferIdx;
<#if DoubleBuffer == true> 
    gfxRect syncRect[SYNC_RECT_COUNT + 1];
    volatile unsigned int syncRectIndex;
    volatile bool swapPending;
</#if>
} DISPLAY_LAYER;
static DISPLAY_LAYER drvLayer[GFX_LCDC_LAYERS];

//This array defines the z-order of the hw layers in the LCDC
//This must be dynamically configured for the LCDC periperal on the part
static LCDC_LAYER_ID lcdcLayerZOrder[GFX_LCDC_LAYERS] =
{
    LCDC_LAYER_BASE,
<#if Overlay1LayerEnable == true>
    LCDC_LAYER_OVR1,
</#if>
<#if HEOLayerEnable == true>
    LCDC_LAYER_HEO,
</#if>
<#if Overlay2LayerEnable == true>
    LCDC_LAYER_OVR2,
</#if>
};


/**** Hardware Abstraction Interfaces ****/
static gfxResult DRV_LCDC_UpdateLayer(unsigned int layer);

void _IntHandlerVSync(uintptr_t context);

static void LCDCUpdateDMADescriptor(LCDC_DMA_DESC * desc, uint32_t addr, uint32_t ctrl, uint32_t next)
{
    desc->addr = addr;
    desc->ctrl = ctrl;
    desc->next = next;
}

void DRV_LCDC_Update()
{
    switch(state)
    {
        case INIT:
        {
<#if DoubleBuffer == true>
            syncLayer = 0;
</#if>
            state = DRAW;
            break;
        }
<#if DoubleBuffer == true>
        case SYNC:
        {
<#if VblankBlit != true>
            if (drvLayer[syncLayer].syncRectIndex == 0)
            {
                syncLayer++;
            }
<#if UseGPU == true && le_gfx_gfx2d??>
            else
            {
                drvLayer[syncLayer].syncRectIndex--;

                gfxGPUInterface.blitBuffer(&drvLayer[syncLayer].pixelBuffer[drvLayer[syncLayer].frontBufferIdx],
                                 &drvLayer[syncLayer].syncRect[drvLayer[syncLayer].syncRectIndex],
                                 &drvLayer[syncLayer].pixelBuffer[drvLayer[syncLayer].backBufferIdx],
                                 &drvLayer[syncLayer].syncRect[drvLayer[syncLayer].syncRectIndex]);
            }
<#else>
            else
            {
                void* srcPtr;
                void* destPtr;
                uint32_t row, rowSize;

                drvLayer[syncLayer].syncRectIndex--;

                rowSize = drvLayer[syncLayer].syncRect[drvLayer[syncLayer].syncRectIndex].width * 
                          gfxColorInfoTable[drvLayer[syncLayer].pixelBuffer[drvLayer[syncLayer].frontBufferIdx].mode].size;

                for(row = 0; row < drvLayer[syncLayer].syncRect[drvLayer[syncLayer].syncRectIndex].height; row++)
                {
                    srcPtr = gfxPixelBufferOffsetGet(&drvLayer[syncLayer].pixelBuffer[drvLayer[syncLayer].frontBufferIdx],
                                        drvLayer[syncLayer].syncRect[drvLayer[syncLayer].syncRectIndex].x,
                                        drvLayer[syncLayer].syncRect[drvLayer[syncLayer].syncRectIndex].y + row);
                    destPtr = gfxPixelBufferOffsetGet(&drvLayer[syncLayer].pixelBuffer[drvLayer[syncLayer].backBufferIdx],
                                        drvLayer[syncLayer].syncRect[drvLayer[syncLayer].syncRectIndex].x,
                                        drvLayer[syncLayer].syncRect[drvLayer[syncLayer].syncRectIndex].y + row);

                    memcpy(destPtr, srcPtr, rowSize);
                }
            }
</#if>
            
            if (syncLayer == GFX_LCDC_LAYERS)
            {
                syncLayer = 0;
                state = DRAW;
            }
</#if>

            break;
        }
</#if>
        case DRAW:
        case SWAP:
        default:
            break;
    }
}

static uint32_t getLCDCStrideFromColorMode(LCDC_INPUT_COLOR_MODE mode)
{
    switch(mode)
    {
        case LCDC_INPUT_COLOR_MODE_LUT8:
            return 1;
            break;
        case LCDC_INPUT_COLOR_MODE_RGB_565:
            return 2;
            break;
        case LCDC_INPUT_COLOR_MODE_RGB_888:
            return 4;
            break;
        case LCDC_INPUT_COLOR_MODE_RGBA_8888:
        case LCDC_INPUT_COLOR_MODE_ARGB_8888:
        default:
            return 4;
            break;
    }    
}

static LCDC_INPUT_COLOR_MODE getLCDCColorModeFromGFXColorMode(gfxColorMode mode)
{
    switch(mode)
    {
        case GFX_COLOR_MODE_GS_8:
            return LCDC_INPUT_COLOR_MODE_LUT8;
            break;
        case GFX_COLOR_MODE_RGB_565:
            return LCDC_INPUT_COLOR_MODE_RGB_565;
            break;
        case GFX_COLOR_MODE_RGB_888:
            return LCDC_INPUT_COLOR_MODE_RGB_888;
            break;
        case GFX_COLOR_MODE_RGBA_8888:
            return LCDC_INPUT_COLOR_MODE_RGBA_8888;
            break;
        case GFX_COLOR_MODE_ARGB_8888:
            return LCDC_INPUT_COLOR_MODE_ARGB_8888;
            break;
        case GFX_COLOR_MODE_INDEX_1:
        case GFX_COLOR_MODE_INDEX_4:
        case GFX_COLOR_MODE_INDEX_8:
        case GFX_COLOR_MODE_RGB_332:
            return LCDC_INPUT_COLOR_MODE_UNSUPPORTED;
            break;
        default:
            return LCDC_INPUT_COLOR_MODE_RGBA_8888;
            break;
    }
}

static gfxColorMode getGFXColorModeFromLCDC(LCDC_INPUT_COLOR_MODE mode)
{
    switch(mode)
    {
        case LCDC_INPUT_COLOR_MODE_LUT8:
            return GFX_COLOR_MODE_GS_8;
        case LCDC_INPUT_COLOR_MODE_RGB_565:
            return GFX_COLOR_MODE_RGB_565;
        case LCDC_INPUT_COLOR_MODE_RGB_888:
            return GFX_COLOR_MODE_RGB_888;
        case LCDC_INPUT_COLOR_MODE_ARGB_8888:
            return GFX_COLOR_MODE_ARGB_8888;
        case LCDC_INPUT_COLOR_MODE_RGBA_8888:
            return GFX_COLOR_MODE_RGBA_8888;
        default:
            return GFX_COLOR_MODE_RGBA_8888;
    }
}

gfxResult LCDC_BrightnessRangeGet(uint32_t *low, uint32_t *high)
{
    *low = 0;
    *high = 100;

    return GFX_SUCCESS;
}

gfxResult LCDC_BrightnessSet(uint32_t brightness)
{

    LCDC_SetPWMCompareValue(brightness * 0xff / 100);

    return GFX_SUCCESS;
}

gfxResult DRV_LCDC_Initialize()
{
    uint32_t      xResolution;
    uint32_t      yResolution;
    uint32_t      rightMargin;
    uint32_t      lowerMargin;
    uint32_t      hsyncLength;
    uint32_t      vsyncLength;
    uint32_t      leftMargin;
    uint32_t      upperMargin;
    uint32_t      layerCount;
<#if CanvasModeOnly == false>
    uint32_t      bufferCount;
</#if>
    
    //Clear the descriptor and structures
    memset(drvLayer, 0, sizeof(drvLayer));

    /* set temporary information */
    xResolution     = ${Val_Width};
    yResolution     = ${Val_Height};
    rightMargin     = ${Val_HorzFrontPorch};
    leftMargin      = ${Val_HorzBackPorch};
    hsyncLength     = ${Val_HorzPulseWidth};
    vsyncLength     = ${Val_VertPulseWidth};
    upperMargin     = ${Val_VertBackPorch};
    lowerMargin     = ${Val_VertPulseWidth};


    /* LCDC initialization */
    //1. Configure the LCD timing parameters
    LCDC_WaitForSyncInProgress();
    LCDC_SetPWMClockSourceSelection(LCDC_PWM_CLOCK_SOURCE);
    LCDC_SetClockDivider(PIXEL_CLOCK_DIV);

    //Disable all layers for now
    LCDC_SetLayerClockGatingDisable(LCDC_LAYER_BASE, false); 
    LCDC_SetLayerClockGatingDisable(LCDC_LAYER_OVR1, false); 
    LCDC_SetLayerClockGatingDisable(LCDC_LAYER_OVR2, false);
    LCDC_SetLayerClockGatingDisable(LCDC_LAYER_HEO, false);
    LCDC_SetLayerClockGatingDisable(LCDC_LAYER_PP, false);

    LCDC_WaitForSyncInProgress();
    LCDC_SetHSYNCPulseWidth(hsyncLength); //Set the pulse widths
    LCDC_SetVSYNCPulseWidth(vsyncLength);

    LCDC_WaitForSyncInProgress();
    LCDC_SetVerticalFrontPorchWidth(lowerMargin); //Set the vertical porches
    LCDC_SetVerticalBackPorchWidth(upperMargin);
    
    LCDC_WaitForSyncInProgress();
    LCDC_SetHorizontalFrontPorchWidth(rightMargin); //Set the horizontal porches
    LCDC_SetHorizontalBackPorchWidth(leftMargin);
    
    LCDC_WaitForSyncInProgress();
    LCDC_SetNumActiveRows(yResolution);
    LCDC_SetNumPixelsPerLine(xResolution);
    
    LCDC_WaitForSyncInProgress();
    LCDC_SetDisplayGuardTime(LCDC_DISPLAY_GUARD_NUM_FRAMES);
    LCDC_SetOutputMode(LCDC_OUTPUT_COLOR_MODE);
    LCDC_SetDisplaySignalSynchronization(true);
    LCDC_SetVSYNCPulseStart(LCDC_SYNC_EDGE);
    LCDC_SetVSYNCPolarity(LCDC_VSYNC_POLARITY);
    LCDC_SetHSYNCPolarity(LCDC_HSYNC_POLARITY);

<#if BacklightPWMEnable == true>
    LCDC_WaitForSyncInProgress();
    LCDC_SetPWMCompareValue(LCDC_DEFAULT_BRIGHTNESS_PCT * 0xFF / 100);
    LCDC_SetPWMSignalPolarity(LCDC_PWM_POLARITY);
    LCDC_SetPWMPrescaler(LCDC_PWM_PRESCALER);
</#if>

    //2. Enable the Pixel Clock
    LCDC_WaitForSyncInProgress();
    LCDC_SetPixelClockEnable(true);
    
    //3. Poll CLKSTS field of the LCDC_LCDSR register to check that the clock is running.
    LCDC_WaitForClockRunning();
    
    // 4. Enable Horizontal and Vertical Synchronization by writing one to the
    // SYNCEN field of the LCDC_LCDEN register.
    LCDC_WaitForSyncInProgress();
    LCDC_SetSYNCEnable(true);
    
    // 5. Check that synchronization is up. */    
    LCDC_WaitForSynchronization();
    
    //6. Enable the display power signal 
    LCDC_WaitForSyncInProgress();
    LCDC_SetDISPSignalEnable(true);
    
    //7. Wait for power signal to be activated
    LCDC_WaitForDISPSignal();
    
    //8. Enable the backlight
    LCDC_WaitForSyncInProgress();
<#if BacklightPWMEnable == true>
    LCDC_SetPWMEnable(true);
</#if>

<#if CanvasModeOnly == false>
<#list 0..(TotalNumLayers-1) as i>
    drvLayer[${i}].baseaddr[0] = framebuffer_${i};
</#list>
<#if DoubleBuffer == true>
<#list 0..(TotalNumLayers-1) as i>
    drvLayer[${i}].baseaddr[1] = framebuffer1_${i};
</#list>
</#if>
</#if>
<#list 0..(TotalNumLayers-1) as i>
    drvLayer[${i}].desc = &channelDesc${i};
</#list>
    
    for (layerCount = 0; layerCount < GFX_LCDC_LAYERS; layerCount++)
    {
        drvLayer[layerCount].hwLayerID = lcdcLayerZOrder[layerCount];
        drvLayer[layerCount].resx       = xResolution;
        drvLayer[layerCount].resy       = yResolution;
        drvLayer[layerCount].startx     = 0;
        drvLayer[layerCount].starty     = 0;
        drvLayer[layerCount].sizex      = drvLayer[layerCount].resx;
        drvLayer[layerCount].sizey      = drvLayer[layerCount].resy;
        drvLayer[layerCount].alpha      = 255;
        drvLayer[layerCount].colorspace = LCDC_DEFAULT_GFX_COLOR_MODE;
        drvLayer[layerCount].frameOffset = 0;
        LCDCUpdateDMADescriptor(drvLayer[layerCount].desc, 
                                (uint32_t) drvLayer[layerCount].baseaddr[0],
                                0x01,
                                (uint32_t) drvLayer[layerCount].desc);
        
<#if CanvasModeOnly == false>
        //Clear frame buffer
        for(bufferCount = 0; bufferCount < BUFFER_PER_LAYER; ++bufferCount)
        {
            memset(drvLayer[layerCount].baseaddr[bufferCount], 0, sizeof(FRAMEBUFFER_PIXEL_TYPE) * DISPLAY_WIDTH * DISPLAY_HEIGHT);
        }
</#if>
       
        LCDC_SetLayerClockGatingDisable(drvLayer[layerCount].hwLayerID, false);
        LCDC_SetWindowPosition(drvLayer[layerCount].hwLayerID, drvLayer[layerCount].startx, drvLayer[layerCount].starty);
<#if HEOLayerEnable == true>
        if (drvLayer[layerCount].hwLayerID == LCDC_LAYER_HEO)
            layerHEOSetSize(drvLayer[layerCount].resx, drvLayer[layerCount].resy, drvLayer[layerCount].resx, drvLayer[layerCount].resy);
        else
            LCDC_SetWindowSize(drvLayer[layerCount].hwLayerID, drvLayer[layerCount].resx, drvLayer[layerCount].resy);
<#else>
        LCDC_SetWindowSize(drvLayer[layerCount].hwLayerID, drvLayer[layerCount].resx, drvLayer[layerCount].resy);
</#if>
        LCDC_SetUseDMAPathEnable(drvLayer[layerCount].hwLayerID, true);
        LCDC_SetRGBModeInput(drvLayer[layerCount].hwLayerID, drvLayer[layerCount].colorspace);
        LCDC_SetDMAAddressRegister(drvLayer[layerCount].hwLayerID, drvLayer[layerCount].desc->addr);
        LCDC_SetDMADescriptorNextAddress(drvLayer[layerCount].hwLayerID, (uint32_t) drvLayer[layerCount].desc);
        LCDC_SetDMAHeadPointer(drvLayer[layerCount].hwLayerID, (uint32_t) drvLayer[layerCount].desc);
        LCDC_SetTransferDescriptorFetchEnable(drvLayer[layerCount].hwLayerID, true);

        //Note: Blender APIs don't do anything to the base layer
        LCDC_SetBlenderOverlayLayerEnable(drvLayer[layerCount].hwLayerID, true);
        LCDC_SetBlenderDMALayerEnable(drvLayer[layerCount].hwLayerID, true); //Enable blender DMA
        LCDC_SetBlenderLocalAlphaEnable(drvLayer[layerCount].hwLayerID, true); //Use local alpha
        LCDC_SetBlenderIteratedColorEnable(drvLayer[layerCount].hwLayerID, true); //Enable iterated color
        LCDC_SetBlenderUseIteratedColor(drvLayer[layerCount].hwLayerID, true); //Use iterated color        
        LCDC_UpdateOverlayAttributesEnable(drvLayer[layerCount].hwLayerID);
        LCDC_UpdateAttribute(drvLayer[layerCount].hwLayerID); //Apply the attributes

        LCDC_SetChannelEnable(drvLayer[layerCount].hwLayerID, true);
        LCDC_IRQ_Enable(LCDC_INTERRUPT_BASE + drvLayer[layerCount].hwLayerID);

        drvLayer[layerCount].frontBufferIdx = 0;
<#if DoubleBuffer != true>
        drvLayer[layerCount].backBufferIdx = 0;
</#if>
        drvLayer[layerCount].updateLock = LAYER_UNLOCKED;

        gfxPixelBufferCreate(xResolution,
                            yResolution,
                            getGFXColorModeFromLCDC(LCDC_DEFAULT_GFX_COLOR_MODE),
                            drvLayer[layerCount].baseaddr[0],
                            &drvLayer[layerCount].pixelBuffer[drvLayer[layerCount].frontBufferIdx]);

<#if DoubleBuffer == true>
        drvLayer[layerCount].backBufferIdx = 1;
        gfxPixelBufferCreate(xResolution,
                            yResolution,
                            getGFXColorModeFromLCDC(LCDC_DEFAULT_GFX_COLOR_MODE),
                            drvLayer[layerCount].baseaddr[1],
                            &drvLayer[layerCount].pixelBuffer[drvLayer[layerCount].backBufferIdx]);
        
        drvLayer[layerCount].syncRectIndex = 0;
        drvLayer[layerCount].swapPending = false;
</#if>
    }

<#if HEOLayerEnable == true>
    //Set HEO layer on top of OVL1
    LCDC_SetHEOVideoPriority(true);
</#if>

    //Register the interrupt handler
    LCDC_IRQ_CallbackRegister(_IntHandlerVSync, (uintptr_t) NULL);
    
    return GFX_SUCCESS;
}

void _IntHandlerVSync(uintptr_t context)
{
    uint32_t i, status;
    LCDC_LAYER_ID layerID;
    
    for (i = 0; i < GFX_LCDC_LAYERS; i++)
    {
        layerID = lcdcLayerZOrder[i];
        status = LCDC_LAYER_IRQ_Status(layerID);

        if (status && drvLayer[i].updateLock == LAYER_LOCKED_PENDING)
        {
            LCDC_LAYER_IRQ_Disable(layerID, LCDC_LAYER_INTERRUPT_DMA);
        }
    }
    
<#if UseGPU == true && le_gfx_gfx2d?? && VblankBlit == true>
    if (blitBuff != NULL)
    {
<#if DoubleBuffer == true> 
    gfxGPUInterface.blitBuffer((const gfxPixelBuffer*) blitBuff,
                                   &srcRect,
                                   &drvLayer[blitLayer].pixelBuffer[drvLayer[blitLayer].backBufferIdx],
                                   &destRect);
<#else>
    gfxGPUInterface.blitBuffer((const gfxPixelBuffer*) blitBuff,
                                   &srcRect,
                                   &drvLayer[blitLayer].pixelBuffer[drvLayer[blitLayer].frontBufferIdx],
                                   &destRect);
</#if>

        gfxPixelBuffer_SetLocked((gfxPixelBuffer*) blitBuff,
                                 LE_FALSE);

        blitBuff = NULL;        
    }
</#if>
    
    //Update LCDC during blanking period
    for (i = 0; i < GFX_LCDC_LAYERS; i++)
    {
        LCDC_LAYER_ID layerID = lcdcLayerZOrder[i];
        status = LCDC_LAYER_IRQ_Status(layerID);

        if (status && drvLayer[i].updateLock == LAYER_LOCKED_PENDING)
        {
            LCDC_LAYER_IRQ_Disable(layerID, LCDC_LAYER_INTERRUPT_DMA);

            DRV_LCDC_UpdateLayer(i);
            drvLayer[i].updateLock = LAYER_UNLOCKED;
        }
    }
    
    for (i = 0; i < GFX_LCDC_LAYERS; i++)
    {
<#if DoubleBuffer == true>     
        switch (state)
        {
            case SWAP:
            {
                if (drvLayer[i].swapPending == false)
                    break;
        
                drvLayer[i].frontBufferIdx = drvLayer[i].backBufferIdx;
                drvLayer[i].backBufferIdx = (drvLayer[i].backBufferIdx == 0) ? 1 : 0;

                LCDCUpdateDMADescriptor(drvLayer[i].desc, 
                                        (uint32_t) drvLayer[i].baseaddr[drvLayer[i].frontBufferIdx],
                                        0x01,
                                        (uint32_t) drvLayer[i].desc);

                drvLayer[i].swapPending = false;
                
                break;
            }
<#if UseGPU == true && le_gfx_gfx2d?? && VblankBlit == true>
            case SYNC:
            {
                if (drvLayer[syncLayer].syncRectIndex == 0)
                {
                    syncLayer++;
                }
                else
                {
                    drvLayer[syncLayer].syncRectIndex--;

                    gfxGPUInterface.blitBuffer(&drvLayer[syncLayer].pixelBuffer[drvLayer[syncLayer].frontBufferIdx],
                                     &drvLayer[syncLayer].syncRect[drvLayer[syncLayer].syncRectIndex],
                                     &drvLayer[syncLayer].pixelBuffer[drvLayer[syncLayer].backBufferIdx],
                                     &drvLayer[syncLayer].syncRect[drvLayer[syncLayer].syncRectIndex]);
                }

                if (syncLayer == GFX_LCDC_LAYERS)
                {
                    syncLayer = 0;
                    state = DRAW;
                }
                
                for (i = 0; i < GFX_LCDC_LAYERS; i++)
                {
                    LCDC_LAYER_ID layerID = lcdcLayerZOrder[i];
                    LCDC_LAYER_IRQ_Enable(layerID, LCDC_LAYER_INTERRUPT_DMA);
                }
                
                break;
            }
</#if>
            default:
                break;
        }
</#if>

        if (drvLayer[i].updateLock == LAYER_LOCKED_PENDING)
        {
            DRV_LCDC_UpdateLayer(i);
            drvLayer[i].updateLock = LAYER_UNLOCKED;
        }
    }

<#if DoubleBuffer == true> 
    if (state == SWAP)
    {
<#if UseGPU == true && le_gfx_gfx2d?? && VblankBlit == true>
        for (i = 0; i < GFX_LCDC_LAYERS; i++)
        {
            LCDC_LAYER_ID layerID = lcdcLayerZOrder[i];
            LCDC_LAYER_IRQ_Enable(layerID, LCDC_LAYER_INTERRUPT_DMA);
        }
</#if>
        state = SYNC;
    }
</#if>
}

/**** End Hardware Abstraction Interfaces ****/

gfxResult DRV_LCDC_BlitBuffer(int32_t x,
                             int32_t y,
                             gfxPixelBuffer* buf)
{
<#if UseGPU == false || !le_gfx_gfx2d??>
    void* srcPtr;
    void* destPtr;
    uint32_t row, rowSize;
</#if>

    if (state != DRAW)
	{
        return GFX_FAILURE;
	}

<#if DoubleBuffer == true>
    if (drvLayer[activeLayer].syncRectIndex < SYNC_RECT_COUNT)
    {
        drvLayer[activeLayer].syncRect[drvLayer[activeLayer].syncRectIndex].x = x;
        drvLayer[activeLayer].syncRect[drvLayer[activeLayer].syncRectIndex].y = y;
        drvLayer[activeLayer].syncRect[drvLayer[activeLayer].syncRectIndex].width = buf->size.width;
        drvLayer[activeLayer].syncRect[drvLayer[activeLayer].syncRectIndex].height = buf->size.height;

        drvLayer[activeLayer].syncRectIndex++;
    }
    else
    {
        drvLayer[activeLayer].syncRect[SYNC_RECT_COUNT].x = 0;
        drvLayer[activeLayer].syncRect[SYNC_RECT_COUNT].y = 0;
        drvLayer[activeLayer].syncRect[SYNC_RECT_COUNT].width = 
                drvLayer[activeLayer].pixelBuffer[drvLayer[activeLayer].backBufferIdx].size.width;
        drvLayer[activeLayer].syncRect[SYNC_RECT_COUNT].height = 
                drvLayer[activeLayer].pixelBuffer[drvLayer[activeLayer].backBufferIdx].size.height;
    }
</#if>

<#if UseGPU == true && le_gfx_gfx2d??>
    srcRect.x = 0;
    srcRect.y = 0;
    srcRect.height = buf->size.height;
    srcRect.width = buf->size.width;

    destRect.x = x;
    destRect.y = y;
    destRect.height = buf->size.height;
    destRect.width = buf->size.width;
    
<#if VblankBlit == true>
    gfxPixelBuffer_SetLocked(buf, LE_TRUE);
    
    blitBuff = buf;
    blitLayer = activeLayer;
    
    LCDC_LAYER_ID layerID = lcdcLayerZOrder[blitLayer];
    LCDC_LAYER_IRQ_Enable(layerID, LCDC_LAYER_INTERRUPT_DMA);
<#else>
<#if DoubleBuffer == true> 
    gfxGPUInterface.blitBuffer(buf, &srcRect, &drvLayer[activeLayer].pixelBuffer[drvLayer[activeLayer].backBufferIdx], &destRect);
<#else>
    gfxGPUInterface.blitBuffer(buf, &srcRect, &drvLayer[activeLayer].pixelBuffer[drvLayer[activeLayer].frontBufferIdx], &destRect);
</#if>
</#if>
<#else>
    rowSize = buf->size.width * gfxColorInfoTable[buf->mode].size;

    for(row = 0; row < buf->size.height; row++)
    {
        srcPtr = gfxPixelBufferOffsetGet(buf, 0, row);
        destPtr = gfxPixelBufferOffsetGet(&drvLayer[activeLayer].pixelBuffer[drvLayer[activeLayer].backBufferIdx], x, y + row);

        memcpy(destPtr, srcPtr, rowSize);
    }
</#if>

    return GFX_SUCCESS;
}

static gfxResult DRV_LCDC_UpdateLayer(unsigned int layer)
{
    if (drvLayer[layer].enabled == true)
        LCDC_SetUseDMAPathEnable(drvLayer[layer].hwLayerID, true);
    else
        LCDC_SetUseDMAPathEnable(drvLayer[layer].hwLayerID, false);

    //Update the active layer's color mode and stride
    LCDC_SetRGBModeInput(drvLayer[layer].hwLayerID, drvLayer[layer].colorspace);
    LCDC_SetDMAAddressRegister(drvLayer[layer].hwLayerID, drvLayer[layer].desc->addr);
    LCDC_SetDMADescriptorNextAddress(drvLayer[layer].hwLayerID, (uint32_t) drvLayer[layer].desc);
    LCDC_SetDMAHeadPointer(drvLayer[layer].hwLayerID, (uint32_t) drvLayer[layer].desc);
    LCDC_SetTransferDescriptorFetchEnable(drvLayer[layer].hwLayerID, true);
        
    LCDC_UpdateAddToQueue(drvLayer[layer].hwLayerID);

    return GFX_SUCCESS;
}

static gfxDriverIOCTLResponse _layerConfig(gfxDriverIOCTLRequest request,
                                           gfxIOCTLArg_LayerArg* arg)
{
    gfxIOCTLArg_LayerValue* val;
    gfxIOCTLArg_LayerPosition* pos;
    gfxIOCTLArg_LayerSize* sz;
    uint32_t baseAddr = 0;
    uint32_t stride = 0;
    int32_t x,y = 0;
    uint32_t width, height = 0;
    
    //Make sure layer is locked before accepting changes
    if (arg->id >= GFX_LCDC_LAYERS)
        return GFX_FAILURE;
    
    if (request == GFX_IOCTL_SET_LAYER_LOCK &&
        drvLayer[arg->id].updateLock == LAYER_UNLOCKED)
    {
        drvLayer[arg->id].updateLock = LAYER_LOCKED;
        
        return GFX_SUCCESS;
    }
    
    //Layer should be locked 
    if (drvLayer[arg->id].updateLock != LAYER_LOCKED)
        return GFX_FAILURE;
    
    if (request == GFX_IOCTL_SET_LAYER_UNLOCK)
    {
        baseAddr = (uint32_t)drvLayer[arg->id].baseaddr[drvLayer[arg->id].frontBufferIdx];
        
        width = drvLayer[arg->id].resx;
        height = drvLayer[arg->id].resy;
        x = drvLayer[arg->id].startx;
        y = drvLayer[arg->id].starty;
        
        if (drvLayer[arg->id].startx < 0)
        {
            //align offsets for 8bpp frames
//            if (gfxColorInfoTable[canvas[canvasID].pixelBuffer.mode].size == 1)
//                drvLayer[arg->id].startx = -(abs(drvLayer[arg->id].startx) & ~0x3);

            baseAddr += abs(drvLayer[arg->id].startx) * 
                    getLCDCStrideFromColorMode(drvLayer[arg->id].colorspace); 

            width += drvLayer[arg->id].startx;
            
            x = 0;
        }

        if (drvLayer[arg->id].starty < 0)
        {
            baseAddr += abs(drvLayer[arg->id].starty) * drvLayer[arg->id].sizex * 
                    getLCDCStrideFromColorMode(drvLayer[arg->id].colorspace); 

            height += drvLayer[arg->id].starty;
            y = 0;
        }

        if (x + width > DISPLAY_WIDTH)
            width = (x < DISPLAY_WIDTH) ? DISPLAY_WIDTH - x : 0;

        if (y + height > DISPLAY_HEIGHT)
            height = (y < DISPLAY_HEIGHT) ? DISPLAY_HEIGHT - y : 0;

        stride = abs(drvLayer[arg->id].sizex - width) * 
                    getLCDCStrideFromColorMode(drvLayer[arg->id].colorspace);
            
        LCDCUpdateDMADescriptor(drvLayer[arg->id].desc, 
                                baseAddr,
                                0x01,
                                (uint32_t) drvLayer[arg->id].desc);

	    LCDC_SetWindowPosition(drvLayer[arg->id].hwLayerID, x, y);
        LCDC_SetHorizStride(drvLayer[arg->id].hwLayerID, stride);

	    LCDC_SetWindowSize(drvLayer[arg->id].hwLayerID, width, height);

        LCDC_SetRGBModeInput(drvLayer[arg->id].hwLayerID, drvLayer[arg->id].colorspace);

#if GLOBAL_ALPHA_ENABLED
        LCDC_SetBlenderGlobalAlpha(drvLayer[arg->id].hwLayerID, drvLayer[arg->id].alpha);        
#else
        //If global alpha is not supported, disable the layer if alpha is = 0 
        if (drvLayer[arg->id].alpha == 0)
            LCDC_SetChannelEnable(drvLayer[arg->id].hwLayerID, false);
        else
#endif        
        LCDC_SetChannelEnable(drvLayer[arg->id].hwLayerID, drvLayer[arg->id].enabled);

        //Update overlay attributes before the start of the next frame
        LCDC_UpdateOverlayAttributesEnable(drvLayer[arg->id].hwLayerID);
        
        drvLayer[arg->id].updateLock = LAYER_UNLOCKED;
        
        return GFX_SUCCESS;
    }
    
    switch(request)
    {
        case GFX_IOCTL_SET_LAYER_ALPHA:
        {
            val = (gfxIOCTLArg_LayerValue*)arg;
            
            drvLayer[arg->id].alpha = val->value.v_uint;
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_SET_LAYER_SIZE:
        {
            sz = (gfxIOCTLArg_LayerSize*)arg;
            
            drvLayer[arg->id].sizex = sz->width;
            drvLayer[arg->id].sizey = sz->height;
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_SET_LAYER_POSITION:
        {
            pos = (gfxIOCTLArg_LayerPosition*)arg;
            
            drvLayer[arg->id].startx = pos->x;
            drvLayer[arg->id].starty = pos->y;
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_SET_LAYER_WINDOW_SIZE:
        {
            sz = (gfxIOCTLArg_LayerSize*)arg;
            
            drvLayer[arg->id].resx = sz->width;
            drvLayer[arg->id].resy = sz->height;
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_SET_LAYER_BASE_ADDRESS:
        {
            val = (gfxIOCTLArg_LayerValue*)arg;
            
            drvLayer[arg->id].baseaddr[drvLayer[arg->id].frontBufferIdx] = val->value.v_pointer;
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_SET_LAYER_COLOR_MODE:
        {
            val = (gfxIOCTLArg_LayerValue*)arg;
            
            drvLayer[arg->id].colorspace = getLCDCColorModeFromGFXColorMode(val->value.v_colormode);
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_GET_LAYER_ENABLED:
        {
            val = (gfxIOCTLArg_LayerValue*)arg;
            
            val->value.v_bool = drvLayer[arg->id].enabled;
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_SET_LAYER_ENABLED:
        {
            val = (gfxIOCTLArg_LayerValue*)arg;
            
            drvLayer[arg->id].enabled = val->value.v_bool;
            
            return GFX_IOCTL_OK;
        }
        default:
            break;
    }
    
    return GFX_IOCTL_UNSUPPORTED;
}

gfxDriverIOCTLResponse DRV_LCDC_IOCTL(gfxDriverIOCTLRequest request,
                                      void* arg)
{
<#if DoubleBuffer == true>
    unsigned int i = 0;
</#if>
    gfxIOCTLArg_Value* val;
    gfxIOCTLArg_DisplaySize* disp;
    gfxIOCTLArg_LayerRect* rect;
    
    switch(request)
    {
        case GFX_IOCTL_LAYER_SWAP:
        {
<#if DoubleBuffer == true>
            if (drvLayer[activeLayer].syncRectIndex > 0)
                drvLayer[activeLayer].swapPending = true;
</#if>
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_FRAME_END:
        {
<#if DoubleBuffer == true>
            state = SWAP;
            for (i = 0; i < GFX_LCDC_LAYERS; i++)
            {
                LCDC_LAYER_ID layerID = lcdcLayerZOrder[i];
                LCDC_LAYER_IRQ_Enable(layerID, LCDC_LAYER_INTERRUPT_DMA);
            }
</#if>
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_GET_BUFFER_COUNT:
        {
            val = (gfxIOCTLArg_Value*)arg;
            
            val->value.v_uint = BUFFER_PER_LAYER;
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_GET_DISPLAY_SIZE:
        {
            disp = (gfxIOCTLArg_DisplaySize*)arg;            
            
            disp->width = DISPLAY_WIDTH;
            disp->height = DISPLAY_HEIGHT;
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_GET_LAYER_COUNT:
        {
            val = (gfxIOCTLArg_Value*)arg;
            
            val->value.v_uint = GFX_LCDC_LAYERS;
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_GET_ACTIVE_LAYER:
        {
            val = (gfxIOCTLArg_Value*)arg;
            
            val->value.v_uint = activeLayer;
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_SET_ACTIVE_LAYER:
        {
            val = (gfxIOCTLArg_Value*)arg;
            
            if(val->value.v_uint >= GFX_LCDC_LAYERS)
            {
                return GFX_IOCTL_ERROR_UNKNOWN;
            }
            else
            {
                activeLayer = val->value.v_uint;
                
                return GFX_IOCTL_OK;
            }
        }
        case GFX_IOCTL_GET_LAYER_RECT:
        {
            rect = (gfxIOCTLArg_LayerRect*)arg;
            
            if(rect->base.id >= GFX_LCDC_LAYERS)        
                return GFX_IOCTL_ERROR_UNKNOWN;
            
            rect->x = drvLayer[rect->base.id].startx;
            rect->y = drvLayer[rect->base.id].starty;
            rect->width = drvLayer[rect->base.id].sizex;
            rect->height = drvLayer[rect->base.id].sizey;
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_GET_VSYNC_COUNT:
        {
            val = (gfxIOCTLArg_Value*)arg;
            
            val->value.v_uint = vsyncCount;
            
            return GFX_IOCTL_OK;
        }
        case GFX_IOCTL_GET_FRAMEBUFFER:
        {
            val = (gfxIOCTLArg_Value*)arg;
            
            val->value.v_pbuffer = &drvLayer[activeLayer].pixelBuffer[drvLayer[activeLayer].frontBufferIdx];

            return GFX_IOCTL_OK;
        }
        default:
        {
            if (request >= GFX_IOCTL_LAYER_REQ_START && 
                request < GFX_IOCTL_LAYER_REQ_END)
            {
                return _layerConfig(request, (gfxIOCTLArg_LayerArg*)arg);
            }
        }
    }
    
    return GFX_IOCTL_UNSUPPORTED;
}

/*******************************************************************************
 End of File
*/
