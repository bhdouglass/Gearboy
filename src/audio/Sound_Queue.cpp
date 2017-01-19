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
	as.setCodec("audio/pcm");
	as.setSampleRate((int)sample_rate);
	as.setChannelCount(chan_count);
	QAudioDeviceInfo info(QAudioDeviceInfo::defaultOutputDevice());

	if (audio == 0) {
	        if (!info.isFormatSupported(as)) {
			qDebug() << "The requested format is not supported: " << as;
			qDebug() << "The nearest format is: " << info.nearestFormat(as);
			qDebug() << "And the prefferred format is: " << info.preferredFormat();
			return "format not supported";
		} else {
			audio = new QAudioOutput(as, this);
		}
	}

    buf = audio->start();
	qDebug() << "Preferred audio format: " << info.preferredFormat();
	qDebug() << "Audio Buffer Size" << audio->bufferSize();
	return NULL;
}


void Sound_Queue::restart()
{
	if (audio) {
		audio->reset();
	}
}


void Sound_Queue::stop()
{
	if (audio) {
		audio->stop();
	}
}


void Sound_Queue::write(const sample_t* in, long count)
{
	if (buf) { 
		buf->write((const char *)in, count * sizeof (sample_t));
	}
}


long Sound_Queue::min_samples()
{
	return audio ? audio->periodSize() / sizeof (sample_t) : 1;
}

long Sound_Queue::max_samples()
{
	return audio ? audio->bytesFree() / sizeof (sample_t) : 100000;
}
