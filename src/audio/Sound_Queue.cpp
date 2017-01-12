#include "Sound_Queue.h"

#include <QDebug>

Sound_Queue::Sound_Queue() : audio(0), buf(0)
{ 
}

Sound_Queue::~Sound_Queue() 
{ 
	if (audio) {
		delete audio;
	}
}


const char* Sound_Queue::start(long sample_rate, int chan_count)
{
	QAudioFormat as;
	as.setSampleType(QAudioFormat::SignedInt);
	as.setSampleSize(16);

	as.setSampleRate((int)sample_rate);
	as.setChannelCount(chan_count);
	if (audio == 0) {
		audio = new QAudioOutput(as, this);
	}
	buf = audio->start();
	return NULL;
}


void Sound_Queue::stop()
{
	if (audio) {
		audio->stop();
	}
}


void Sound_Queue::write(const sample_t* in, int count)
{
	if (buf) { 
		buf->write((const char *)in, count * sizeof (sample_t));
	}
}
