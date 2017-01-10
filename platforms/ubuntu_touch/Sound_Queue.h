#ifndef SOUND_QUEUE_H
#define SOUND_QUEUE_H

#include <QAudioOutput>
#include <QBuffer>
#include <QIODevice>
#include <QObject>

class Sound_Queue : public QObject {
Q_OBJECT
public:
	Sound_Queue();
	~Sound_Queue();
	
	typedef short sample_t;

	// Initialize with specified sample rate and channel count.
	const char* start(long sample_rate, int chan_count = 1);

	void write(const sample_t*, int count);

	// Stop audio output
	void stop();

private:	
	QAudioOutput *audio;
	QIODevice *buf;
};

#endif

