/*
 * Gearboy - Nintendo Game Boy Emulator
 * Copyright (C) 2012  Ignacio Sanchez

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses/ 
 * 
 */

#include "Audio.h"
#include "Memory.h"


#include <QDebug>

Audio::Audio()
{
    m_bCGB = false;
    m_bEnabled = true;
    m_Time = 0;
    m_AbsoluteTime = 0;
    m_iSampleRate = 44100;
    InitPointer(m_pApu);
    InitPointer(m_pBuffer);
    InitPointer(m_pSound);
    InitPointer(m_pSampleBuffer);
}

Audio::~Audio()
{
    SafeDelete(m_pApu);
    SafeDelete(m_pBuffer);
    SafeDelete(m_pSound);
    SafeDeleteArray(m_pSampleBuffer);
}

void Audio::Init()
{
    int msecs = 250;
    int channels = 2;
    m_pSampleBuffer = new blip_sample_t[kSampleBufferSize];

    m_pApu = new Gb_Apu();

    m_pSound = new Sound_Queue();

    m_pSound->start(m_iSampleRate, channels);
    qDebug() << "Sample Buffer Size: " << kSampleBufferSize;
    qDebug() << "Blargg Blip Sample Size: " << int(m_iSampleRate * channels * msecs / 1000.0);
    if (channels == 2) {
        Stereo_Buffer *buffer = new Stereo_Buffer();
        m_pBuffer = buffer;
         m_pApu->set_output(buffer->center(), buffer->left(), buffer->right());
    } else {
        Mono_Buffer* buffer = new Mono_Buffer();
        m_pBuffer = buffer;
        m_pApu->set_output(buffer->center());
    }

    m_pBuffer->clock_rate(4194304);
    m_pBuffer->set_sample_rate(m_iSampleRate, msecs);

    m_pApu->reduce_clicks();
    m_pApu->treble_eq(-15.0);
    m_pBuffer->bass_freq(100);
}

void Audio::Reset(bool bCGB, bool soft)
{
    m_bCGB = bCGB;
    
    if(!soft)
    {
        Gb_Apu::mode_t mode = m_bCGB ? Gb_Apu::mode_cgb : Gb_Apu::mode_dmg;
        m_pApu->reset(mode);
        m_pBuffer->clear();
        for (int reg = 0xFF10; reg <= 0xFF3F; reg++)
        {
            u8 value = m_bCGB ? kInitialValuesForColorFFXX[reg - 0xFF00] : kInitialValuesForFFXX[reg - 0xFF00];
            m_pApu->write_register(0, reg, value);
        }
        m_Time = 0;
        m_AbsoluteTime = 0;
    }
}

void Audio::Enable(bool enabled)
{
    m_bEnabled = enabled;
}

bool Audio::IsEnabled() const
{
    return m_bEnabled;
}


void Audio::EndFrame()
{
	m_pApu->end_frame(m_AbsoluteTime);
	m_pBuffer->end_frame(m_AbsoluteTime);

    if (m_pBuffer->samples_avail() >= kSampleBufferSize) { // while (m_pBuffer->samples_avail())
            long count = m_pBuffer->read_samples(m_pSampleBuffer, kSampleBufferSize);
			if (m_bEnabled) {
                m_pSound->write(m_pSampleBuffer, count);
			}
	}
}
