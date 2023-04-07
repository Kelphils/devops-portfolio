import React, { useEffect, useState, useContext } from 'react';
import { Chrono } from 'react-chrono';
import { Container } from 'react-bootstrap';
import PropTypes from 'prop-types';
import ReactMarkdown from 'react-markdown';
import Fade from 'react-reveal';
import { ThemeContext } from 'styled-components';
import endpoints from '../constants/endpoints';
import Header from './Header';
import FallbackSpinner from './FallbackSpinner';
import '../css/education.css';

// styles properties section
const styles = {
  introTextContainer: {
    whiteSpace: 'pre-wrap',
  },
};

const renderItems = (items) => (
  <div>
    {items.map((item) => (
      <div key={item.name}>
        <br />
        <div>
          <div style={{ arginzLeft: '10px' }}>{item.year}</div>
          <a
            href={item.href}
            target="_blank"
            rel="noopener noreferrer"
            style={{ color: 'blue', textDecoration: 'none' }}
          >
            {item.name}
          </a>
        </div>
      </div>
    ))}
  </div>
);
function Education(props) {
  const theme = useContext(ThemeContext);
  const { header } = props;
  const [data, setData] = useState(null);
  const [width, setWidth] = useState('50vw');
  const [mode, setMode] = useState('VERTICAL_ALTERNATING');
  const renderIntro = (intro) => (
    <h4 style={styles.introTextContainer}>
      <ReactMarkdown children={intro} />
    </h4>
  );

  useEffect(() => {
    fetch(endpoints.education, {
      method: 'GET',
    })
      .then((res) => res.json())
      .then((res) => setData(res))
      .catch((err) => err);

    if (window?.innerWidth < 576) {
      setMode('VERTICAL');
    }

    if (window?.innerWidth < 576) {
      setWidth('90vw');
    } else if (window?.innerWidth >= 576 && window?.innerWidth < 768) {
      setWidth('90vw');
    } else if (window?.innerWidth >= 768 && window?.innerWidth < 1024) {
      setWidth('75vw');
    } else {
      setWidth('50vw');
    }
  }, []);

  return (
    <>
      <Header title={header} />
      {data ? (
        <Fade>
          <div style={{ width, fontType: 'Roboto', fontSize: '13.5px' }} className="section-content-container">
            <Container>
              <Chrono
                hideControls
                allowDynamicUpdate
                useReadMore={false}
                items={data.education}
                cardHeight={250}
                mode={mode}
                theme={{
                  primary: theme.accentColor,
                  secondary: theme.accentColor,
                  cardBgColor: theme.chronoTheme.cardBgColor,
                  cardForeColor: theme.chronoTheme.cardForeColor,
                  titleColor: theme.chronoTheme.titleColor,
                }}
              >
                <div />
              </Chrono>
            </Container>
          </div>
          {data ? (
            <div className="section-content-container">
              <Fade>
                {/* Render certificate section */}
                <Container>
                  {renderIntro(data.intro)}
                  {data['Trainings and Certifications']?.map((section) => (
                    <div key={section.title} style={{ display: 'inline-block', fontSize: '20px' }}>
                      <h1>{section.title}</h1>
                      {renderItems(section.items)}
                    </div>
                  ))}
                </Container>
              </Fade>
            </div>
          ) : (
            <FallbackSpinner />
          )}
        </Fade>
      ) : (
        <FallbackSpinner />
      )}
    </>
  );
}

Education.propTypes = {
  header: PropTypes.string.isRequired,
};

export default Education;
