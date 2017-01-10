#include "Sound_Queue.h"

#include <QDebug>

Sound_Queue::Sound_Queue() { }

Sound_Queue::~Sound_Queue() { stop(); }


const char* Sound_Queue::start(long sample_rate, int chan_count)
{
	QAudioFormat as;
	as.setSampleRate((int)sample_rate);
	as.setSampleType(QAudioFormat::SignedInt);
	as.setSampleSize(16);
	as.setChannelCount(chan_count);
	audio = new QAudioOutput(as, this);
	buf = audio->start();
	return NULL;
}


void Sound_Queue::stop()
{
	if (audio) {
		audio->stop();
		delete audio;
		audio = 0;
		buf = 0;
	}
}


void Sound_Queue::write(const sample_t* in, int count)
{
	if (buf) { 
		buf->write((const char *)in, count * sizeof (sample_t));
	}
}
