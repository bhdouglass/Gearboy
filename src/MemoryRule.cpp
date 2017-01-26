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

#include "MemoryRule.h"

#include <QDebug>


MemoryRule::MemoryRule(Processor* pProcessor, Memory* pMemory,
        Video* pVideo, Input* pInput, Cartridge* pCartridge, Audio* pAudio)
{
    m_pProcessor = pProcessor;
    m_pMemory = pMemory;
    m_pVideo = pVideo;
    m_pInput = pInput;
    m_pCartridge = pCartridge;
    m_pAudio = pAudio;
    m_bCGB = false;
    InitPointer(m_pRamChangedCallback);
    InitPointer(m_pFileStore);
}

MemoryRule::~MemoryRule()
{
    SafeDelete(m_pFileStore);
}


void MemoryRule::RAMChanged()
{
	if (IsValidPointer(m_pRamChangedCallback)) {
	    (*m_pRamChangedCallback)();
	}
	if (IsValidPointer(m_pFileStore)) {
        std::ofstream out(m_pFileStore->c_str(), std::ofstream::out | std::ofstream::binary);
        SaveRam(out);
	}
}

void MemoryRule::SaveRam(std::ofstream&)
{
    Log("Save RAM not implemented");
}

bool MemoryRule::LoadRam(std::ifstream&, s32)
{
    Log("Load RAM not implemented");
    return false;
}

void MemoryRule::SetFileStore(std::string filestore)
{
    m_pFileStore = new std::string(filestore);
}

void MemoryRule::SetRamChangedCallback(RamChangedCallback callback)
{
    m_pRamChangedCallback = callback;
}
