#ifndef SOUND_QUEUE_H
#define SOUND_QUEUE_H

#include <QAudioOutput>
#include <QIODevice>
#include <QObject>

class Sound_Queue : public QObject 
{
	Q_OBJECT
public:
	Sound_Queue();
	~Sound_Queue();
	
	typedef short sample_t;

	const char* start(long sample_rate, int chan_count = 1);

	void write(const sample_t*, long count);

	void stop();
	void restart();

	long min_samples();
	long max_samples();

private:	
	QAudioOutput *audio;
	QIODevice *buf;
};

#endif

