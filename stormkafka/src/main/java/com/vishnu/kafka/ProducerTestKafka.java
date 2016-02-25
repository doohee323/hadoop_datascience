package com.vishnu.kafka;

import java.util.Properties;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import backtype.storm.utils.Utils;
import kafka.javaapi.producer.Producer;
import kafka.producer.KeyedMessage;
import kafka.producer.ProducerConfig;

public class ProducerTestKafka {

	private static final Log log = LogFactory.getLog(ProducerTestKafka.class);

	private static final String KAFKA_HOST_PORT = "192.168.82.150:9092";
	private static final String TOPIC = "incoming";

	private Producer<Object, String> kproducer;

	private static String type = "";
	public static void main(String[] args) {
		type = args[0];
		if(type == null) {
			type = "solr";
		}
	
		ProducerTestKafka source = new ProducerTestKafka();
		source.init();
		source.populate();
		source.close();
	}

	private void init() {
		Properties props = new Properties();
		props.put("metadata.broker.list", KAFKA_HOST_PORT);
		props.put("serializer.class", "kafka.serializer.StringEncoder");
		props.put("request.required.acks", "1");

		ProducerConfig config = new ProducerConfig(props);
		kproducer = new Producer<Object, String>(config);
	}

	private void populate() {
		for (int i = 0; i < 10; i++) {
			String test = "";
			if(type.equals("solr")) {
				test = "solr id:" + i + " value:solr_message";				
			} else if(type.equals("hdfs")) {
				test = "hdfs this message goes to hdfs";
			}
			System.out.println("=============" + test);
			kproducer.send(new KeyedMessage<Object, String>(TOPIC, test));
		}
		Utils.sleep(500);
	}

	private void close() {
		kproducer.close();
	}
}
