detectedLocations = num2cell(2*randn(1,40) + (1:40));
detectedLocations{1} = [];
for idx = 16: 25
    detectedLocations{idx} = [];
end
figure;
hold on;
ylabel('Location');
ylim([0,50]);
xlabel('Time');
xlim([0,length(detectedLocations)]);
kalman = [];
for idx = 1: length(detectedLocations)
    location = detectedLocations{idx};
    if isempty(kalman)
        if ~isempty(location)
            
            stateModel = [1 1;0 1];
            measurementModel = [1 0];
            kalman = vision.KalmanFilter(stateModel,measurementModel,'ProcessNoise',1e-4,'MeasurementNoise',4);
            kalman.State = [location, 0];
        end
    else
        trackedLocation = predict(kalman);
        if ~isempty(location)
            plot(idx, location,'k+');
            d = distance(kalman,location);
            title(sprintf('Distance:%f', d));
            trackedLocation = correct(kalman,location);
        else
            title('Missing detection');
        end
        pause(0.2);
        plot(idx,trackedLocation,'ro');
    end
end
legend('Detected locations','Predicted/corrected locations');