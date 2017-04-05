function pred1 = mvr_prediction(data, mdata, output)

ts = data.trial{1};
ttime = data.time{1};
coeffs = mdata.coeffs;
[nvars, ~, nlags] = size(coeffs);

switch output
    case 'parameters'
        H = hankel(1:nlags, nlags:length(ttime)-1)';
        X = [];

        for i = 1:nvars
            tsi = ts(i, :);
            X = [X, tsi(H)];
        end

        W = reshape(coeffs, nvars, []);
        pred1 = W * X';

        % compare results:
        cfg = mdata.cfg;
        cfg.output = 'model';
        res = ft_mvaranalysis(cfg, data);
        pred2 = res.trial{1};
        time = res.time{1};

        i = 1;
        figure; hold on;
        plot(ttime, ts(i, :));
        plot(time, pred2(i, :));
        plot(time, pred1(i, :));
        legend('True', 'Predicted', 'Coeffs')
    case 'residual'
        cfg = mdata.cfg;
        cfg.output = 'residual';
        res = ft_mvaranalysis(cfg, data);
        figure;
        imagesc(res.trial{1});
        colorbar;
    case 'model'
        cfg = mdata.cfg;
        cfg.output = 'model';
        res = ft_mvaranalysis(cfg, data);
        pred2 = res.trial{1};
        time = res.time{1};
        i = 1;
        figure; hold on;
        plot(ttime, ts(i, :));
        plot(time, pred2(i, :));
        legend('True', 'Predicted');
end
end